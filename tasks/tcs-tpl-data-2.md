# Доработки по предыдущей задаче tcs-tpl-data, правки в проекте br-tcs

Была сделана задача, исходный промпт которой лежит в файле /Users/h1/projects/scripts-mac-work/tasks/tcs-tpl-data.md.
Задача сейчас уже сделана, в коде проекта br-tcs есть сделанные правки по ней.
В текущей новой задаче нужно внести изменения, исправления и доработки.
Далее по шагам.

## В пакете notificationtemplatedata структуру/сервис resolver разделить на множество сервисов

Сейчас по всем kind логика поиска данных для шаблона сведена в одну общую кучу.
Это нехорошо, потому что в будущем одни и те же названия переменных
в разных шаблонах могут иметь очень разную логику поиска данных для их заполнения.
Поэтому, для каждого отдельного notification_template_kind должна быть создана
отдельная самостоятельная структура, со своим конструктором и зависимостями,
со своим захардкоженным список используемых плейсхолдеров для данного шаблона,
и со своими публичными методами, реализующуюими общий интерфейс.
Это должны быть прямо отдельные структуры, без каких либо общих
встраиваемых базовых структур.
Не бойся того что в итоге это приведет к дублированию кода, это "кажущееся" дублирование,
основная цель этой задачи не сделать минимум кода, а сделать максимум поддерживаемости
этого кода в будущем. Текущая версия, которая сделана в прошлой задаче - это свалка, которую в долгосроке поддерживать и расширять не получится.
Общий у них нужен будет только конфиг с предопределенными значениями плейсхолдеров (как сейчас). Также можно использовать общую функцию firstString для удобства.

Пример интерфейса который должны реализовать новые сервисы по каждому kind:

```go
type TemplateDataBuilder interface {
	SupportedKind() string // всегда вернет конкретный template kind по которому он специализируется
	Build(ctx context.Context, req BuildRequest) (string, error)
}
```

А вот пример скелета одной из реализаций.
У каждой реализации должна быть возможность пробросить свои собственные уникальные зависимости
через конструктор.

```go
type VerificationEmailDataBuilder struct {
	cfg Config
	logger Logger
	fields []string
}

func NewVerificationEmailDataBuilder(cfg Config, logger Logger) *VerificationEmailDataBuilder {
	return &VerificationEmailDataBuilder{
		cfg: cfg,
		logger: logger,
		fields: []string{"CurrentYear", "Domain", "VerifyURL"},
	}
}

func (b *VerificationEmailDataBuilder) SupportedKind() string {
	return "verification_email"
}

func (b *VerificationEmailDataBuilder) Build(ctx context.Context, req BuildRequest) (string, error) {
	// здесь логика сборки данных
}
```

Соответственно сервис-фасад должен реально начать выполнять роль фасада.

```go
type Facade struct {
	builders map[string]TemplateDataBuilder
}

func (f *Facade) Build(ctx context.Context, templateKind string, req BuildRequest) (string, error) {
	builder, ok := f.builders[templateKind]
	if !ok {
		return "", fmt.Errorf(...)
	}

	return builder.Build(ctx, req)
}
```

И вот этот фасад уже пробрасывай как зависимость (через интерфейс) в воркер, который отправляет уведомления.