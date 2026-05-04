# Система рисковых правил, правки в проекте br-risk-monitoring

Технически система похожа на то, чтобы недавно было реализовано в соседнем
проекте br-tcs. Проанализируй код который там есть,
и при совпадении логики с тем что написано в этой задаче, 
копипасти код, адаптировав под все отличия (отличия чаще только в названиях, а также в наборе полей).

## Базовые структуры данных и сущности

### Сущность RiskEventLog

Сгенерируй сущность и миграцию, на основе вот такого SQL-кода:

```sql
CREATE TABLE risk_event_log (
    id              UUID      PRIMARY KEY,
    user_id         UUID    NOT NULL,
    event_at        TIMESTAMPTZ    NOT NULL,
    created_at      TIMESTAMPTZ    DEFAULT NOW(),
    event_category  VARCHAR(32)    NOT NULL,  -- 'lifecycle'|'financial'|'trading'|'risk'|'analytics'|'comm'|'system'|'client'
    event_type      VARCHAR(64)    NOT NULL,  -- from canonical dictionary above
    metadata        JSONB,                    -- threshold_label for D1, custom fields
    INDEX idx_user_time  (user_id, event_at),
    INDEX idx_category   (event_category, event_type)
);
```

## Сущность TriggerRule

Сгенерируй сущность и миграцию для нее на основе этого SQL (если в SQL есть ошибки синтаксиса - исправь их в миграции):

```sql
CREATE TABLE trigger_rules (
    id        VARCHAR(255)   PRIMARY KEY,
    name      VARCHAR(255)   NOT NULL,
    trigger_formula VARCHAR(255) NOT NULL,
    outcome_action VARCHAR(255) NULL,
    settings JSONB NULL,
    active            BOOLEAN       DEFAULT TRUE,
    created_at        TIMESTAMPTZ   DEFAULT NOW(),
    updated_at        TIMESTAMPTZ   DEFAULT NOW(),
    INDEX idx_trigger_trigger_formula   (trigger_formula),
    INDEX active   (active)
);
```

В коде для поля outcome_action запили enum с возможными значениями (русскоязычные пояснения сделай комментариями в коде):

auto-pass — пропустить;
flag-soft — пропустить, но записать подозрение;
hold-4h, hold-24h, hold-manual — задержать операцию;
block-account — заморозить аккаунт;
block-trading — запретить новые сделки;
reject-payment — отклонить платёж;
hold-credit — деньги пришли, но не зачислять до проверки;
hold-payout — вывод одобрен в UI, но деньги ещё не отправлять;
reject-bonus — не выдать бонус;
void-bonus — отменить уже выданный бонус;
hold-affiliate-payout — задержать выплату партнёру;
suspend-partner — временно заморозить партнёра;
terminate-partner — окончательно отключить партнёра.

В самой БД пусть останется строкой, чтобы можно было расширять список без боли.

## Сгенерируй DTO с событием RiskEvent

В этом новом проекте мы будем получать события из кафки в виде DTO и складывать их в БД
в RiskEvent. О самой логике обработки ниже, а сейчас подготовь DTO которое получать из кафки.

Название базового объекта: dto.RiskEvent.
В нем должно быть обяательно строковое поле EventType (json: event_type),
а также строковое enum-поле Category (с возможными значениями: lifecycle, financial, trading, risk, analytics, comm, system, client).

И поле с кастомной json-строкой MetaData.

## Кафка-воркер, складывающий события в БД

Нужно запилить кафка-воркер, который будет читать сообщения типа dto.RiskEvent,
и создавать по каждому полученному событию соответствующий экземпляр сущности
RiskEventLog, заполнять его данными из dto, и сохранять в БД.

# Реализация обработки триггеров по событиям

Сейчас все события приходят из кафки и складываются в risk_event_log.
Также есть в БД таблица с настройками триггеров trigger_rules, 
там правила срабатывания триггеров и описание действий, которые нужно совершить
при срабатывании.
Нужно реализовать саму логику срабатывания триггеров в соответствии с правилами 
и условиями.

Далее по шагам.

## Новая сущность Incident (аналог сущности Task в br-tcs)

Создай новую сущность Incident, в ней такие поля:
- id (uuid, primary key)
- user_id (uuid, index)
- trigger_rule_id (varchar(255))
- risk_event_ids (массив из uuid, по умолчанию пустой)
- status (varchar(255), index) - в БД строка, а в коде тоже строка но с вариантами ready_to_process, pending, processing, complete, canceled, error
- status_message (text, nullable)
- data (JSONB в БД, string в коде, nullable)
- created_at
- updated_at

## Создать пул сервисов в пакете triggerformulas

Общий интерфейс который реализуют: TriggerFormula.
Вот как он должен выглядеть:

```go
type TriggerExecutionRequest struct {
	Event *entity.RiskEventLog
	Rule *entity.TriggerRule
}

type TriggerFormula interface {
	Name() string // всегда будет возвращать захардкоженный slug формулы, который реализует
	IsTriggered(event *entity.RiskEventLog) bool
	Execute(ctx context.Context, req TriggerExecutionRequest) error
}
```

Во вложенном пакете будут лежать множественные реализации этого интерфейса,
ВАЖНО: каждая реализация формулы - это отдельная самостоятельная структура без каких-либо
базовых вложенных структур, и для каждой реализации отдельный файл.
Создай пока по такой схеме просто тестовый пример-заглушку реализации с именем "test", который 
ничего не делает.
Наполнением конкретных формул займемся в следующих задачах.

### Фасад для этого пула сервисов

Фасад должен реализовать интерфейс как показано ниже, и такой интерфейс потом пробрасывай
везде где потребуется.

```go
type TriggerFormulaFacade interface {
	IsTriggered(formulaName string, event entity.RiskEventLog) bool
	Execute(ctx context.Context, formulaName string, req TriggerExecutionRequest) error
}
```

Под капотом сами сервисы-формулы лежать в map[string]TriggerFormula,
где ключ у мапы - его name.
При вызове каждого метода фасада находишь нужный экземпляр TriggerFormula по его name и пробрасываешь вызов в него.

## Создай и реализуй пакет (сервис) TriggerChecker, определяющий, подходит ли заданное клиентское событие под какой-нибудь TriggerRule

В данном сервисе один публичный метод CheckTriggeredRules: на вход получает экзепляр сущности RiskEventLog,
на выходе либо соответствующий массив TriggerRule, под которые данное событие подходит.
Если не подходит ни под одно правило, то вернуть пустой массив.

Внутри надо делать поиск по существующим TriggerRule, у которых active==true,
по каждому TriggerRule дергать метод TriggerFormulaFacade.IsTriggered(TriggerRule.TriggerFormula).
Если true, то добавлять в массив подошедших правил.

### Кеширование всех TriggerRule в памяти

Для быстроты поиска триггерных правил, их надо выгрузить все из БД в массив сущностей в отдельном поле сервиса, 
и отдельным воркером периодически
обновлять (делать заново select в бд и обновлять соответствующий кеш), защищая RW-мьютексом.
Соответственно в методе поиска правила для события поиск делать уже только по массиву в памяти.

## Новый пакет (сервис) event processor

Этот сервис будет заниматься непосредственно созданием и исполнением инцидентов (Incident),
на основе событий и сработавших триггерных правил.

У него должен быть всего один публичный метод. Вот интерфейс который он должен реализовать:
```go
type EventProcessor interface {
	OnEvent(ctx context.Context, clientEvent *entity.RiskEventLog) error
}
```

Пробрось этот интерфейс зависимостью в worker.clientevents (а после реализации и его реализацию через DI).
Вызывай этот метод сразу после сохранения
события. Если EventProcessor вернул ошибку, логируй ее, но не возвращай из воркера.

### Реализация публичного метода OnEvent

В течение всего выполнения данного метода должен быть установлен лок на UserID и название данного метода.
Далее сама логика выполнения метода:

В самом начале дерни метод TriggerChecker.CheckTriggeredRules.
Если не вернулось ни одного правила, сразу выходи без ошибок.

Если вернулся непустой массив сработавших правил, пройдись циклом по массиву
и по каждому правилу дерни метод-обработчик TriggerFormulaFacade.Execute().

## Новый пакет OutcomeActions - пул сервисов

В этом пакете должен лежать пул сервисов, фасад которого реализует такой интерфейс:

```go
type OutcomeActionsFacade interface {
	PerformOutcomeAction(ctx context.Context, action entity.OutcomeAction, incident *entity.Incident) error
}
```

В этом пакете должен лежать пул сервисов, реализующих такой нижестоящий интерфейс:

```go
type OutcomeActionPerformer interface {
	Name() entity.OutcomeAction // всегда вернуть захардкоженное значение реализуемого action из enum
	PerformOutcomeAction(ctx context.Context, incident *entity.Incident) error
}
```

Сгенерируй множество заглушек реализаций для каждого существующего OutcomeAction,
в соответствии со списком значений данного enum, указанного в секции про сущность TriggerRule.


## БД-воркер для процессинга ранее созданных инцидентов

В этом воркере каждые 5 секунд ищешь в БД идентификаторы инцидентов со статусом ready_to_process.
По каждому найденному ID дергаем новый приватный метод-обработчик.
В этом методе сначала ставим лок на incident id, затем подгружаем из БД свежую копию сущности Incident по ее ID,
удостоверимся что ее статус действительно ready_to_process. Если статус другой, выходим без ошибок.
Далее ставим статус processing, сохраняем в БД.
После этого приступаем к полезной логике.

Полезная логика в текущей версии пусть будет простая.
Находим в БД триггерное правило по trigger_rule_id.

Если у триггерного правила не указан никакой OutcomeAction,
выходим без ошибок.

Если указан, то дергаем метод OutcomeActionsFacade.PerformOutcomeAction для данного инцидента.