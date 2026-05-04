# Добавь новые триггер-формулы - заглушки для реализаций интерфейса triggerformulas.TriggerFormula

В пакете triggerformulas создан пул сервисов, реализующих общий интерфейс TriggerFormula
c общим фасадом. Также создан пример одной реализации-заглушки "test".

Нужно по списку ниже сделать такие же реализации-заглушки для каждой формулы.
Делай все как "test", одна структура = один файл, внутри файла в комметариях к коду 
на русском языке напиши текстом описание формулы (скопируй из списка ниже).
Пробрось DI в пул сервисов.

## Вот список формул:

Ниже — список по смыслу: ID правила (name, начинается на AF-) → простое объяснение.

1. Регистрация / KYC
Hard reject / block

AF-KYC-027 — duplicate device + disposable email
Если человек регистрируется с устройства, которое уже использовалось, и при этом ставит временную почту — регистрацию закрывают. По отдельности эти сигналы не блокируют, но вместе это похоже на фабрику мультиаккаунтов.

AF-KYC-002 / AF-KYC-004 — sanctions / OFAC / FATF confirmed
Если клиент точно совпал с санкционными списками или чёрными списками, аккаунт блокируется. Клиенту не объясняют конкретную причину, чтобы не раскрывать AML-логику.

AF-KYC-006 — blocked country
Если страна клиента или IP попадает во внутренний список запрещённых юрисдикций, сервис недоступен. Это правило про географические и регуляторные ограничения.

AF-KYC-003a — confirmed minor
Если KYC подтвердил, что клиенту меньше 18 лет, аккаунт блокируется. Это не “подозрение”, а жёсткое возрастное ограничение.

AF-KYC-001 — SumSub final RED
Если SumSub вернул финальный отказ по KYC, аккаунт блокируется. Обычно это поддельные документы, failed liveness, deepfake или другой серьёзный KYC fail.

AF-KYC-007 — high document reuse
Если один и тот же документ уже использовался в другой регистрации, аккаунт блокируется или уходит в жёсткую проверку. Идея — ловить повторное использование паспортов и документов.

AF-KYC-008 confirmed — confirmed fake documents
Если подделка документов подтверждена несколькими сигналами, аккаунт блокируется. Это не мягкая проверка, а прямой fraud-сценарий.

AF-KYC-028a — hard fingerprint duplicate + UBO match
Если устройство совпадает с другим аккаунтом и совпадает реальный владелец/платёжные признаки, это считается жёстким дублем. Аккаунт замораживается как вероятный мультиаккаунт.

Manual review

AF-KYC-005 — PEP detected
Если клиент — PEP или связан с PEP, его не блокируют автоматически. Его отправляют на enhanced due diligence.

AF-KYC-003b — age cannot be determined
Если возраст нельзя нормально подтвердить по документам, регистрацию ставят на ручную проверку. Клиента просят дать более понятный документ или скан.

AF-KYC-008 suspected — suspected fake documents
Если есть один сигнал подделки, но уверенности недостаточно, аккаунт не блокируют сразу. Его отправляют на manual review.

AF-KYC-009 — FATF grey-list country
Если клиент из FATF grey-list страны, это повышенный риск, но не автоматический бан. Клиента проверяют глубже.

AF-KYC-028b — soft fingerprint duplicate
Если устройство совпадает, но владелец может быть другим, это не жёсткий бан. Например, семейный компьютер, офисный компьютер или публичное устройство.

AF-KYC-030 — rapid multi-account creation
Если с одного IP или устройства быстро создают много аккаунтов, регистрацию задерживают. Это типичный признак фарминга аккаунтов.

Soft friction

AF-PAY-DEP-003a — sanctioned IP geo-block
Если пользователь заходит или пытается сделать депозит с IP из санкционной зоны, сессия блокируется. Сам аккаунт при этом не обязательно банится.

AF-KYC-014a + AF-PAY-DEP-035 — disposable email single signal
Если временная почта — клиенту показывают баннер и ограничивают депозит. Сама регистрация не убивается.

AF-KYC-016 — VPN / proxy / Tor / datacenter
VPN или прокси просто добавляют риск-скор. Сам по себе VPN не блокирует, потому что легитимные клиенты тоже часто им пользуются.

AF-KYC-019 — anomalously fast KYC
Если KYC прошёл подозрительно быстро, это добавляет маленький риск-скор. Клиент ничего не видит, правило работает тихо.

2. Пополнения / Deposits
Hard reject

AF-PAY-DEP-002a — deposit to blocked account, pre-capture
Если аккаунт заблокирован, карточный или e-wallet депозит отклоняется до списания денег. Это защита от закидывания денег на уже проблемный аккаунт.

AF-PAY-DEP-004 — active AML hold
Если на аккаунте активная AML-проверка, депозит отклоняется. Деньги не должны заходить, пока compliance не разобрался.

AF-PAY-DEP-013a1 — anonymous gift / prepaid BIN, pre-capture
Если карта выглядит как анонимная gift/prepaid карта, депозит не принимается. Смысл — не принимать плохо идентифицируемый источник средств.

AF-PAY-DEP-015a — 3DS failed
Если клиент не прошёл 3DS, платёж отклоняется. Это стандартная защита по картам.

AF-PAY-DEP-035 — disposable email at deposit
Если у клиента временная почта, депозит блокируется до замены email. Это enforcement после мягкого KYC-флага.

Hold-credit

AF-PAY-DEP-002b — async funds on blocked account
Если банк или крипта уже прислали деньги на заблокированный аккаунт, деньги не зачисляются в wallet. Они удерживаются до review и потенциального refund.

AF-PAY-DEP-006a — confirmed cardholder mismatch
Если имя на карте сильно не совпадает с KYC-именем, депозит удерживается. Это защита от чужих или украденных карт.

AF-PAY-DEP-007 — bank transfer sender mismatch
Если банковский перевод пришёл не от имени клиента, деньги не зачисляются сразу. Нужно проверить источник средств.

AF-PAY-DEP-008 — e-wallet holder mismatch
Если владелец e-wallet не совпадает с клиентом, депозит удерживается. Это аналог проверки ownership для электронных кошельков.

AF-PAY-DEP-013a2 — prepaid/gift BIN detected post-capture
Если деньги уже списались, а потом BIN оказался gift/prepaid, зачисление стопорится. Дальше нужен review или возврат.

AF-PAY-DEP-016 — BIN-testing pattern
Если было много отказов по картам, а потом один успех, это похоже на тестирование украденных карт. Депозит удерживают.

AF-PAY-DEP-023b — first deposit ≥ annual declared income
Если первый депозит больше или равен годовому заявленному доходу, это AML-красный флаг. Деньги удерживаются до проверки source of funds.

AF-PAY-DEP-030 — crypto below confirmations
Если криптодепозит ещё не набрал нужное число подтверждений, он не зачисляется. Это operational integrity, а не обязательно fraud.

AF-PAY-DEP-031 — crypto wrong network
Если клиент отправил актив не в той сети, депозит не зачисляется автоматически. Нужен treasury recovery flow.

Manual review

AF-PAY-DEP-003b — FATF grey-list IP
Если IP указывает на grey-list юрисдикцию, депозит идёт на enhanced monitoring. Это не бан, а дополнительная осторожность.

AF-PAY-DEP-009a — crypto address linked to another GLEX account
Если криптоадрес уже связан с другим аккаунтом, это cluster-сигнал. Проверяют, не мультиаккаунт ли это.

AF-PAY-DEP-009b — shared CEX hot-wallet without KYT
Если депозит пришёл с общего адреса биржи и нет нормального KYT, его проверяют вручную. Сам по себе CEX-адрес не доказывает fraud.

AF-PAY-DEP-011 — new payment method on high-score account
Если рисковый аккаунт впервые использует новый способ оплаты, депозит задерживают. Это ловит попытку сменить источник денег после подозрений.

AF-PAY-DEP-014a — card cycling > 5 cards in 24h
Если за сутки пробуют больше пяти карт, это похоже на stolen-card testing. Такой депозит нужно проверить.

AF-PAY-DEP-014b — card cycling 3–5 cards in 24h
Если карт меньше, но всё равно много, это более мягкий сигнал. Обычно это review, а не моментальный отказ.

AF-PAY-DEP-020 — excessive failed attempts
Если клиент слишком много раз неуспешно пытается оплатить, это подозрительно. Может быть brute force по картам или PSP-тестирование.

AF-PAY-DEP-021 — method switching after declines
Если после отказов по карте клиент резко переключается на крипту, это флаг. Логика — проверить, не пытается ли он обойти card-risk controls.

AF-PAY-DEP-022 — deposit volume spike
Если депозитный объём резко вырос относительно обычного поведения клиента и похожих клиентов, нужен review. Это может быть как легитимный рост, так и AML/fraud.

AF-PAY-DEP-023a — first deposit ≥ 0.5× declared income
Если первый депозит больше половины заявленного годового дохода, это мягкий SoF-сигнал. Его не блокируют сразу, но проверяют.

AF-PAY-DEP-024 — multiple payment methods simultaneously
Если клиент одновременно использует много разных способов оплаты, это подозрительно. Может быть попытка размазать источник средств.

AF-PAY-DEP-025 — bonus activation pattern exceeds threshold
Если депозит выглядит заточенным под бонусный абьюз, его проверяют. Например, повторяемые суммы или связь с бонусными схемами.

AF-PAY-DEP-026 — Founder Access park-no-trading
Если деньги заведены под Founder Access и долго просто лежат без торговли, это AML-сигнал. Сценарий похож на “завёл → подержал → вывел”.

AF-PAY-DEP-027 — recurring deposits at bonus cap
Если депозиты регулярно идут ровно на границе максимального бонуса, это structuring. Система проверяет, не оптимизируют ли депозит под выкачивание бонуса.

AF-PAY-DEP-028 — multiple deposits across fingerprint cluster
Если группа связанных аккаунтов массово пополняется, это cluster-риск. Проверяют мультиаккаунтинг.

AF-PAY-DEP-029 — crypto KYT not connected bridge
Пока KYT не подключён, криптодепозиты идут через ручной контроль. Это временное правило-заглушка.

AF-PAY-DEP-032 — crypto address reuse
Повторное использование криптоадреса контролируется как operational-risk сигнал. Особенно важно, если адрес связывает несколько аккаунтов.

AF-PAY-DEP-019 — crypto exchange origin bridge
Если депозит пришёл с биржи, но KYT ещё нет, это bridge-review. Нужна ручная оценка происхождения средств.

AF-PAY-DEP-033/034 — ledger reconciliation drift
Если ledger и PSP/blockchain не сходятся, депозит стопорится. Это защита от ошибочного зачисления или потери денег.

Soft flags

AF-PAY-DEP-005 — currency mismatch
Если валюта платежа не совпадает с ожидаемой и автоконверсия выключена, добавляется риск-скор. Это не fraud само по себе.

AF-PAY-DEP-006b — partial cardholder mismatch
Если имя на карте похоже, но не идеально совпадает, это мягкий сигнал. Например, транслитерация или сокращённое имя.

AF-PAY-DEP-010 — BIN country mismatch
Если страна карты не совпадает со страной проживания, это добавляет риск. У путешественников такое бывает легитимно.

AF-PAY-DEP-012 — virtual prepaid non-anonymous
Виртуальная prepaid-карта повышает риск, но не всегда запрещена. Поэтому это silent score.

AF-PAY-DEP-013b — corporate/commercial BIN on retail account
Если розничный клиент платит корпоративной картой, это странно. Система добавляет риск-скор.

AF-PAY-DEP-015b — 3DS skipped
Если 3DS не был пройден из-за конфигурации PSP, liability хуже. Это тихий риск-флаг.

AF-PAY-DEP-017 — high chargeback BIN
Если BIN карты исторически даёт много chargeback, депозит помечается. Это защита от карточного риска.

AF-PAY-DEP-018 — young e-wallet
Если e-wallet слишком новый, это повышает риск. Новые кошельки часто используются в fraud-сценариях.

3. Снятия / Withdrawals
Hard reject

AF-PAY-WD-002 — account blocked / suspended
Если аккаунт заблокирован, вывод отклоняется. Деньги не должны уходить с проблемного аккаунта.

AF-PAY-WD-003 — active AML hold
Если есть активная AML-проверка, вывод отклоняется или стопорится. Это защита от вывода до завершения compliance.

AF-PAY-WD-007 — exceeds free margin / balance
Если клиент пытается вывести больше свободного баланса, вывод отклоняется. Это базовая проверка баланса.

AF-PAY-WD-008 — would breach margin requirements
Если вывод приведёт к проблемам с маржой по открытым позициям, его отклоняют. Клиенту надо уменьшить сумму или закрыть позиции.

AF-PAY-WD-009 — negative balance state
Если аккаунт в отрицательном балансе, вывод невозможен. Сначала нужно урегулировать баланс.

AF-PAY-WD-020a — fully covered by disputed deposit exposure
Если вывод полностью покрыт спорным депозитом, его отклоняют. Это защита от chargeback-сценария.

AF-PAY-WD-020c — dispute exposure bridge without ledger
Если есть dispute exposure, но ещё нет нормального fund-source ledger, вывод отклоняется как временная защита. Это bridge-правило до полноценной инфраструктуры.

AF-PAY-WD-034 — invalid crypto address
Если криптоадрес не проходит формат или checksum, вывод отклоняется. Это защита от ошибочных и невозможных транзакций.

AF-PAY-WD-041 — duplicate payout attempt
Если один и тот же withdrawal_id пытаются отправить повторно, вывод отклоняется. Это защита от double payout.

AF-PAY-WD-042 — pre-broadcast without ledger debit
Если payout пытаются отправить без предварительного списания в ledger, это стоп. Это критичный integrity gate против внутренних ошибок.

AF-KYC-048 — withdrawal before KYC step 1
Вывод без минимального KYC запрещён всегда, даже если депозиты до определённого порога разрешены без KYC. Депозит может быть frictionless, вывод — нет.

Hold-payout

AF-PAY-WD-001b — expired KYC document
Если документ KYC истёк, вывод задерживается. Нужно обновить верификацию.

AF-PAY-WD-004 — active trading restriction
Если торговля уже ограничена, вывод тоже проверяют. Это предотвращает вывод денег во время расследования.

AF-PAY-WD-005 — pending compliance review
Если по аккаунту идёт compliance review, вывод не отправляют сразу. Сначала должен завершиться кейс.

AF-PAY-WD-006 — dormant account > 180 days
Если аккаунт долго спал, а потом запросил вывод, это риск. Нужна проверка, что аккаунт не захвачен.

AF-PAY-WD-010 — unsettled bonus funds
Если в выводе есть неотработанные бонусные деньги, payout задерживается. Нужно отделить собственные средства от бонусных.

AF-PAY-WD-011 — ledger mismatch
Если баланс и journal не сходятся, вывод стопорится. Нельзя отправлять деньги при сломанной бухгалтерской картине.

AF-PAY-WD-012a — card target mismatch
Если карта вывода не совпадает с картой депозита, вывод задерживают. Это ownership-control.

AF-PAY-WD-012b — IBAN target mismatch
Если IBAN вывода не совпадает с ранее подтверждённым банковским источником, нужен review. Это защита от вывода на чужой счёт.

AF-PAY-WD-013 — target name mismatch
Если имя получателя вывода не совпадает с KYC-именем, вывод задерживается. Деньги должны уходить владельцу аккаунта.

AF-PAY-WD-014 — crypto target used by another GLEX client
Если криптоадрес вывода уже использовал другой клиент, это cluster-сигнал. Нужно проверить связь аккаунтов.

AF-PAY-WD-015 — e-wallet target held by different person
Если e-wallet принадлежит не клиенту, вывод задерживается. Это аналог банковского name mismatch.

AF-PAY-WD-016 — cross-method asymmetry
Если депозит был только картой, а вывод сразу в крипту, это подозрительно. Может быть попытка обойти chargeback или AML trail.

AF-PAY-WD-017a2 — new destination + high risk score
Если новый адрес вывода появляется у рискового клиента, payout задерживается. Это частый признак account takeover или fraud.

AF-PAY-WD-017a3 — new destination + recent password reset
Если клиент недавно сбросил пароль и сразу добавил новый адрес вывода, это риск захвата аккаунта. Вывод уходит на review.

AF-PAY-WD-017b — destination changed within 24h
Если адрес вывода поменяли за сутки до вывода, payout задерживается. Это cooling-off против угона аккаунта.

AF-PAY-WD-018 — recent card funds within chargeback window
Если деньги недавно пришли с карты и ещё есть chargeback-риск, вывод удерживается. Компания ждёт, чтобы не потерять средства при chargeback.

AF-PAY-WD-019 — high chargeback BIN
Если карта из рискованного BIN, вывод задерживается. Это не доказывает fraud, но повышает риск.

AF-PAY-WD-020b — withdrawal overlaps disputed exposure
Если часть вывода пересекается со спорным депозитом, payout задерживается. Нужно отделить чистые средства от спорных.

AF-PAY-WD-021 — withdrawal > 80% recent card deposits
Если клиент быстро выводит большую часть недавних карточных депозитов, это риск. Может быть “card in → cash/crypto out”.

AF-PAY-WD-023 — bonus profit before turnover met
Если прибыль от бонуса хотят вывести до выполнения оборота, вывод задерживается. Проверяется bonus eligibility.

AF-PAY-WD-023i — bonus bridge without attribution engine
Если нет движка, который отделяет бонусную прибыль от обычной, вывод задерживается. Это временная защита до внедрения bonus attribution.

AF-PAY-WD-024 — Welcome Bonus anomalous turnover
Если прибыль по Welcome Bonus выглядит подозрительно по обороту, вывод задерживается. Например, слишком быстрый или искусственный turnover.

AF-PAY-WD-026 — Founder Access park-no-trading withdrawal
Если деньги лежали без торговли и потом выводятся, это AML-risk. Похоже на layering: завёл, подержал, вывел.

AF-PAY-WD-027 — affiliate commission > tier eligible
Если партнёрская комиссия больше того, что положено по tier, вывод задерживается. Нужно пересчитать партнёрскую выплату.

AF-PAY-WD-028 — active AML exit-structuring case
Если есть подозрение на structuring при выходе денег, вывод задерживается. Клиенту причину подробно не раскрывают.

AF-PAY-WD-030 — synchronized cluster withdrawals
Если связанные аккаунты одновременно выводят деньги, это cluster-risk. Часто так закрывают fraud-схему.

AF-PAY-WD-032 — anomalous geo/device
Если вывод запрашивают с необычного устройства или географии, payout задерживают. Это защита от account takeover.

AF-PAY-WD-035 — crypto KYT screening hold
Если криптоадрес связан с санкциями, миксерами или рискованными сущностями, вывод задерживается. Нужен KYT/compliance review.

AF-PAY-WD-036 — KYT not connected interim
Если KYT ещё не подключён, криптовыводы идут через ручной review. Это временный контроль.

AF-PAY-WD-038 — crypto destination change after recent deposit
Если после недавнего депозита резко меняется криптоадрес вывода, это риск. Возможно, пытаются “отравить” chain trail.

AF-PAY-WD-040 — crypto stuck in broadcast
Если криптотранзакция зависла на этапе broadcast, создаётся контрольный кейс. Это operational-risk, не всегда fraud.

AF-PAY-WD-047 — on-chain mismatch / reorg / double-spend
Если on-chain состояние не совпадает с ожидаемым, вывод стопорится. Это защита от chain reorg и double-spend сценариев.

Time-bounded hold

AF-PAY-WD-017a1 — new destination + low risk score
Если новый адрес вывода у нормального клиента, ставится короткая задержка на 4 часа. Если новых сигналов нет — вывод отпускается.

AF-PAY-WD-029 — rapid sequence of withdrawals
Если выводы идут серией, включается 4-часовой cooling-off. Это мягкая защита от быстрых cash-out сценариев.

AF-PAY-WD-033 — sudden destination change after long stable history
Если клиент долго выводил на один адрес, а потом резко сменил его, ставится 24-часовая задержка. Это защита от угона аккаунта.

AF-PAY-WD-037 — crypto withdrawal to no-history destination
Если криптовывод идёт на новый адрес без истории, ставится 4-часовая задержка. Для низкого риска это не manual review, а пауза.

4. Открытие торговых счетов

AF-KYC-001/002/006 family — master account blocked
Если основной аккаунт заблокирован, новый trading sub-account не создаётся. Иначе sub-account стал бы обходом блокировки.

AF-KYC family — confirmed minor / sanctions / fake docs
Если причина блокировки жёсткая — несовершеннолетний, санкции, fake docs — новые торговые счета тоже запрещены. Compliance-state наследуется.

AF-AML-001a/b, AF-AML-007a — active AML hold
Если AML-кейс активен, торговля на новом счёте недоступна. Новый счёт может быть создан только с ограничениями или не активируется.

AF-KYC-002 re-screen — expired KYC document
Если документы устарели, перед новым торговым счётом нужна повторная проверка. Это re-verification gate.

Composite case state — compliance review pending
Если аккаунт уже на compliance review, новые торговые операции блокируются. Это защита от обхода через дополнительные счета.

AF-KYC-030 + Trading composite — rapid sub-account creation
Если клиент быстро создаёт много торговых субсчетов, это идёт на review. Такое поведение может быть подготовкой к бонусному или торговому абьюзу.

AF-PROMO-005a — Welcome Bonus on ineligible account type
Если клиент пытается получить Welcome Bonus на Prime AI или Raw Pro AI, бонус отклоняется. Сам счёт открыть можно, но без бонуса.

AF-PROMO-006 — bonus eligibility cluster signal
Если cluster history показывает прошлый бонусный абьюз, новый счёт допускается без бонусных возможностей. Это не бан торговли, а ограничение promo.

AF-CORE-031a — high aggregate risk score
Если общий риск-скор высокий, sub-account может быть создан в restricted mode. Например, close-only или с ограничением плеча.

5. Партнёрские счета / Affiliate
Hard reject

AF-PART-002a1 — sanctions match at application
Если компания или UBO партнёра совпали с санкционными списками, заявку отклоняют. Это редкий, но жёсткий regulatory case.

AF-PART-035 — confirmed self-funded fake-client at CPA claim
Если партнёр и “клиент” фактически один и тот же UBO, CPA не должен выплачиваться. Это попытка получить комиссию за самого себя.

AF-PART-050c — confirmed intentional self-dealing in multi-tier
Если после review доказано, что многоуровневая структура создана для self-dealing, партнёра отключают. Это уже не ошибка оформления, а злоупотребление.

Suspend / terminate active partner

AF-PART-002a2 — sanctions on active partner
Если активный партнёр позже попал под санкционный матч, партнёрство прекращается. Pending payouts могут быть заморожены или forfeited.

AF-PART-050c — confirmed self-dealing in multi-tier
Подтверждённая схема самоначисления комиссий ведёт к termination. Это считается тяжёлым нарушением партнёрки.

AF-PART-060b2 — repeated self-referral
Если партнёр системно приводит самого себя или подконтрольные аккаунты, его отключают. Это повторный self-referral, а не разовый спорный случай.

AF-PART-002b2 — PEP/RCA without EDD on active partner
Если активный партнёр оказался PEP/RCA без завершённого EDD, его временно замораживают. Новая traffic acceptance и выплаты ставятся на паузу.

AF-PART-012 — misleading ads / brand impersonation
Если партнёр вводит клиентов в заблуждение или незаконно использует бренд GLEX, его приостанавливают. Это защита от репутационного и legal-risk.

AF-PART-050b — suspected same-UBO multi-tier
Если есть подозрение на same-UBO multi-tier структуру, партнёра ставят на review. Сам same UBO не всегда fraud, поэтому нужен разбор.

AF-PART-051 — circular sub-partner graph
Если партнёрская структура образует цикл A → B → A, это подозрительно. Такая схема может накручивать уровни комиссий.

AF-PART-060b1 — confirmed self-referral first event
При первом подтверждённом self-referral партнёра можно suspended для review. Это обратимое действие, не обязательно termination.

Hold / clarification

AF-PART-001 — KYB/KYC incomplete or fail
Если партнёр загрузил неполные документы, заявку не надо сразу отклонять. Её ставят на hold и просят донести документы.

AF-PART-002b1 — PEP/RCA at onboarding
Если PEP/RCA обнаружен на этапе заявки, onboarding ставится на EDD. Это не автоматический отказ.

AF-PART-005 — domain ownership not verified
Если владение доменом не подтвердилось, партнёру дают альтернативные способы проверки. Например DNS TXT, meta-tag или email admin@domain.

AF-PART-050a — sub-partner same UBO disclosure
Если sub-partner имеет того же UBO, это не бан. Нужно раскрыть структуру и проверить, нет ли commission stacking.

Channel-level controls

AF-PART-010b — prohibited traffic source confirmed
Если один traffic source запрещён, отключают конкретный канал, а не всего партнёра. Это более точечное и менее разрушительное действие.

AF-PART-003b — traffic source changed without approval
Если активный партнёр изменил или скрыл источник трафика, выплаты по этому каналу удерживаются. Партнёр остаётся активным по нормальным каналам.

AF-PART-011b — confirmed incentivized traffic
Если конкретный канал покупает регистрации или стимулирует фейковых клиентов, канал отключается. Весь партнёр не обязательно банится.

Soft friction

AF-PART-003a — traffic source not disclosed at onboarding
Если партнёр не указал источники трафика, заявка не убивается. Но начисление комиссий gated до disclosure.

AF-PART-070 — cookie stuffing
Если партнёр пытается подкидывать affiliate-cookie без реального привлечения клиента, payout по conversion удерживается или отклоняется. Статус партнёра не обязательно меняется.

AF-PART-071 — last-click hijacking
Если партнёр перехватывает последнюю атрибуцию вместо реального источника клиента, payout по conversion проверяется. Это спор атрибуции, а не всегда бан партнёра.

AF-PART-072 — duplicate attribution
Если одна conversion засчиталась нескольким партнёрам, payout удерживается или пересчитывается. Задача — не платить дважды за одного клиента.

6. Бонусы / Promo
Reject bonus

AF-PROMO-001a — duplicate verified identity pre-credit
Если клиент уже получал бонус на другой верифицированной личности/аккаунте, новый бонус не начисляется. Это правило “один бонус на одного клиента”.

AF-PROMO-002a — activation from blocked country
Если клиент из запрещённой страны, бонус не активируется. Это гео/compliance restriction.

AF-PROMO-010a — multiple Welcome Bonus pre-credit
Если система видит вторую попытку получить Welcome Bonus до начисления, бонус отклоняется. Правило ловит повторный claim.

AF-PROMO-031 — Founder Access duplicate UBO
Если Founder Access пытается получить тот же UBO через другой аккаунт, заявка отклоняется. Это защита лимитированных мест и бонусов.

AF-PROMO-003 — active AML hold
Если у клиента активный AML-кейс, бонус не активируется. Нельзя добавлять промо-деньги поверх compliance-проблемы.

AF-PROMO-004 — KYC re-verification
Если клиент проходит повторную KYC-проверку, бонус ставится на паузу. Сначала нужно закончить verification.

AF-PROMO-005a — ineligible account type pre-credit
Welcome Bonus не работает на Prime AI / Raw Pro AI. Если клиент пытается активировать бонус там, bonus reject.

AF-PROMO-025a — cardholder mismatch pre-credit
Если deposit ownership не подтверждён, Deposit Bonus не начисляется. Бонус не должен выдаваться на деньги с чужой карты.

Void / clawback

AF-PROMO-001b — duplicate identity discovered post-credit
Если дубль личности нашли уже после начисления, бонус и связанная прибыль аннулируются. Это post-credit reversal.

AF-PROMO-002b — country reclassification after activation
Если страна клиента после начисления стала blocked, бонус может быть void. Это защита от изменения regulatory status.

AF-PROMO-005b — post-credit ineligible account type
Если бонус ошибочно начислили на неподходящий тип счёта, его отменяют. Это исправление нарушения account-type policy.

AF-PROMO-010b — multiple Welcome Bonus cluster discovered later
Если позже обнаружили cluster с несколькими Welcome Bonus, бонусы аннулируются. Это мультиаккаунтный bonus abuse.

AF-PROMO-025b — cardholder mismatch post-credit
Если mismatch по карте подтвердился после начисления бонуса, бонус отменяют. Потому что ownership денег не подтверждён.

AF-PROMO-050b — confirmed cluster farming on device fingerprint
Если подтверждена ферма аккаунтов по устройствам, бонусы void. Это уже не одиночный сигнал, а доказанный cluster abuse.

AF-PROMO-051b — confirmed cluster farming on payment fingerprint
Если ферма аккаунтов связана через платёжные признаки, бонусы аннулируются. Это сильный мультиаккаунтный сигнал.

AF-PROMO-063b — confirmed hedge cluster losing-side bonus abuse
Если подтверждён hedge-кластер с бонусным абьюзом, бонусы и прибыль отменяются. Это классический cross-account bonus arbitrage.

Manual review

AF-PROMO-006 — bonus activation from cluster with prior abuse
Если аккаунт связан с кластером, где уже был бонусный абьюз, бонус идёт на review. Автоматически не начисляется.

AF-PROMO-012 — Welcome Bonus turnover via scalp
Если оборот Welcome Bonus сделан очень короткими сделками, это подозрительно. Проверяется, не накручен ли turnover.

AF-PROMO-013 — 20 lots in <24h on volatile concentrated
Если 20 лотов набраны меньше чем за сутки на волатильных инструментах, это флаг. Может быть legitimate, но требует review.

AF-PROMO-014 — profit > 10× bonus value
Если прибыль по бонусу слишком большая относительно бонуса, это аномалия. Проверяют win-rate и торговый паттерн.

AF-PROMO-020 — Deposit Bonus stacking pattern
Если клиент активирует Deposit Bonus слишком много раз, это флаг. Особенно опасно при отсутствии лимита на количество бонусов.

AF-PROMO-021 — anomalous Deposit Bonus turnover
Если оборот по Deposit Bonus выглядит как scalp или mirror, бонус проверяют. Цель — ловить искусственный turnover.

AF-PROMO-022 — skim-and-run
Если клиент выполнил turnover и сразу бежит выводить прибыль, это проверяется. Может быть схема “отыграл минимум → вывел”.

AF-PROMO-023 — repeat exact $5K cap deposits from cluster
Если связанные аккаунты повторяют депозиты ровно на максимальный бонусный cap, это structuring. Проверяется cluster abuse.

AF-PROMO-030 — Founder Access funding without trading >14d
Если Founder Access пополнен, но торговли нет больше 14 дней, это park-pattern. Может быть AML layering.

AF-PROMO-040 — short trade duration skew
Если слишком большая доля сделок короче 60 секунд, бонусный turnover подозрителен. Это scalp-like pattern.

AF-PROMO-041 — turnover concentration >80% single instrument
Если почти весь бонусный оборот сделан на одном инструменте, это флаг. Может быть эксплуатация конкретной волатильности или условий.

AF-PROMO-042 — turnover via mirror trades
Если оборот создан зеркальными сделками, это подозрительно. Проверяют, не гоняются ли лоты без реального риска.

AF-PROMO-043 — turnover via opposing positions
Если связанные аккаунты открывают противоположные позиции, это hedge abuse. Один аккаунт проигрывает, другой выигрывает.

AF-PROMO-050a — suspected device cluster farming
Если устройства указывают на ферму аккаунтов, бонус идёт на review. Подтверждения ещё недостаточно для void.

AF-PROMO-051a — suspected payment cluster farming
Если платёжные признаки связывают много бонусных аккаунтов, это review. Это может быть family/corporate edge case, поэтому не всегда auto-void.

AF-PROMO-053 — shared withdrawal target
Если бонусные аккаунты выводят на один и тот же target, это сильный cluster-сигнал. Проверяют мультиаккаунтинг.

AF-PROMO-060 — mirror trade signature in cluster
Если PnL связанных аккаунтов зеркален, это похоже на cross-account hedge. В бонусном контексте это особенно опасно.

AF-PROMO-061 — net exposure ≈ 0 + lot proportionality
Если общий риск группы почти нулевой, а лоты пропорциональны, это может быть искусственный turnover. Проверяют cluster.

AF-PROMO-062 — time-aligned opposite positions
Если противоположные сделки открываются почти одновременно, это hedge-схема. Особенно плохо, если есть бонус.

AF-PROMO-063a — hedge withdrawal pattern, winning side pending
Если выигравшая сторона hedge-кластера пытается вывести деньги, payout/bonus идёт на review. Это момент, где компания может потерять деньги.

AF-PROMO-070b — bonus expired with profit existing
Если бонус истёк, но есть прибыль, она проверяется. Нужно понять, какая часть прибыли относится к бонусу.

AF-PROMO-070i — bridge without bonus attribution engine
Если bonus attribution engine ещё не внедрён, expired-bonus profit проверяется вручную. Это временный fallback.

AF-PROMO-081a — suspected cross-account hedge generating rebates
Если связанные аккаунты хеджируются ради rebate, начисления проверяются. Это rebate abuse, не обычная торговля.

AF-PROMO-083 — many cluster accounts reach high rebate tier
Если много связанных аккаунтов одновременно достигают высокого rebate tier, это подозрительно. Похоже на накрутку объёма.

Rebate

AF-PROMO-080a — suspected rebate-driving wash trades
Если сделки похожи на wash-trading ради rebate, rebate не начисляется до проверки. Цель — не платить cashback за искусственный объём.

7. Конкурсы
Reject / disqualify

AF-CONTEST-020 — timestamp manipulation
Если время заявки выглядит подменённым или не совпадает server/client timestamp, участника дисквалифицируют. Это защита от попытки подать прогноз задним числом.

AF-CONTEST-022 — multiple submissions from same client
Если один клиент отправил несколько заявок, засчитывается только первая. Последующие отклоняются.

AF-CONTEST-030 — support ticket modified after deadline
Если прогноз в support ticket меняли после дедлайна, участника дисквалифицируют. Это закрывает риск инсайдерского или ручного редактирования.

AF-CONTEST-031a — invalid format before deadline
Если формат заявки неверный, но дедлайн ещё не прошёл, её отклоняют с возможностью исправить. Это не fraud, а validation gate.

AF-CONTEST-031b — invalid format remained at deadline
Если неправильный формат не исправили до дедлайна, entry дисквалифицируется. После дедлайна исправлять уже нельзя.

AF-CONTEST-040 — duplicate UBO submission
Если один и тот же реальный человек участвует через несколько аккаунтов, оставляют только самую раннюю заявку. Остальные дисквалифицируются.

AF-CONTEST-043b — confirmed cluster brute-force prize farming
Если после review подтверждена группа аккаунтов, перебирающая варианты ради приза, заявки дисквалифицируют. Это конкурсный мультиаккаунтинг.

AF-CONTEST-050 — confirmed employee submission
Если участвует сотрудник, заявка дисквалифицируется. Конкурс открыт клиентам, не внутренним людям.

Hold-contest-entry

AF-CONTEST-032a — KYC not verified but deadline allows
Если KYC ещё не завершён, но время есть, entry удерживают вне ranking до проверки. Клиент может успеть пройти KYC.

AF-CONTEST-041 — multiple submissions from device cluster
Если много заявок идут с одного device cluster, их удерживают на review. Это может быть семья/офис, а может быть ферма.

AF-CONTEST-042 — multiple submissions from payment cluster
Если участники связаны платёжными признаками, заявки проверяют. Цель — поймать один UBO под разными аккаунтами.

AF-CONTEST-043a — wide forecast range across cluster
Если кластер аккаунтов подаёт широкий набор прогнозов, это похоже на brute force. Entry исключают из ranking до review.

AF-CONTEST-051 — family member / RCA of employee
Если участник связан с сотрудником, entry проверяют. Это риск инсайда или конфликта интересов.

AF-CONTEST-061 — winner KYC at prize allocation
Перед выдачей приза проверяют KYC победителя. Без eligibility prize не должен уходить.

AF-CONTEST-062 — prize delivery to alternative recipient
Если приз хотят отправить не на имя KYC-клиента, delivery проверяется. Это защита от передачи приза третьему лицу.

Void-prize

KYC not completed by deadline — contest-disqualify / void-prize
Если победитель не прошёл KYC к дедлайну, приз может быть отменён. Это зависит от момента обнаружения.

Winner later found ineligible / duplicate / employee — void-prize
Если после allocation выяснилось, что победитель не имел права участвовать, приз отменяется. Если приз уже доставлен, нужен recovery workflow.

8. Торговля

Главный принцип торгового домена: почти всё сначала идёт в trade-review, а не в автоматическую блокировку. В документе прямо сказано, что из 39 trading rules только 3 дают client-facing automatic action: AF-TRADE-030b, AF-TRADE-052, AF-TRADE-081.

A. Latency arbitrage

AF-TRADE-001 — sub-tick fill anomaly
Ищет сделки, где клиент системно получает цену лучше статистически ожидаемой. Это может быть latency arbitrage.

AF-TRADE-002 — positive deviation from market mid
Если входы клиента регулярно лучше market mid, это HFT-style sniping signal. Клиента не блокируют сразу, а отправляют pattern на review.

AF-TRADE-003 — quote-staleness exploit
Если ордера приходят во время задержки фида, это похоже на эксплуатацию stale quote. Нужны LP tick-data и latency telemetry.

AF-TRADE-004 — latency-arb cluster
Если несколько аккаунтов используют одну и ту же latency hole, это cluster-risk. Обычно решение — перевести поток в A-book/hedged routing.

AF-TRADE-005 — cross-LP price arbitrage
Если клиент эксплуатирует разницу цен между liquidity providers, это мягкий флаг. Само по себе не блокирует клиента.

B. Internalized flow / asymmetric P&L

AF-TRADE-010 — broker-loss concentration on internalized flow
Ищет концентрацию убытков брокера на internalized flow. Это больше dealing/risk telemetry, чем клиентский бан.

AF-TRADE-011 — profit-only internalized, loss-only STP
Если прибыльные сделки клиента остаются внутри, а убыточные уходят на STP, это странный execution pattern. Может указывать на internal control issue.

AF-TRADE-012 — negative net flow vs broker book
Если клиент или cluster стабильно токсичен для broker book, это идёт на review. Решение чаще routing, не блокировка.

AF-TRADE-013 — profitable client volume spike
Если прибыльный клиент резко увеличил объём, это просто сигнал для dealing desk. Прибыльный клиент не равен мошенник.

C. Scalping / short-duration

AF-TRADE-020 — very short trades with material P&L
Если сделки очень короткие и дают значимую прибыль, это scalp pattern. Обычно review/routing, не блок.

AF-TRADE-021 — high-frequency same-instrument cycle
Если клиент постоянно открывает и закрывает один инструмент, это HFT/scalp signal. Проверяется контекст и тип аккаунта.

AF-TRADE-022 — scalping on low-spread instruments
Скальпинг на low-spread инструментах добавляет риск. Сам по себе это soft flag.

AF-TRADE-023 — anomalous order-cancel ratio
Если клиент слишком часто ставит и отменяет ордера, это подозрительно. Может быть bot или manipulation pattern.

D. Mirror trading / hedge clusters

AF-TRADE-030a — suspected mirror trade signature
Если PnL связанных аккаунтов зеркально коррелирует, это hedge/mirror signal. Без подтверждения это review.

AF-TRADE-030b — confirmed mirror trade pattern
После L2-confirmation cluster переводится в close-only mode. Это одно из немногих trading rules с прямым client-facing ограничением.

AF-TRADE-031 — net exposure ≈ 0 + lot proportionality
Если группа аккаунтов суммарно почти не рискует, но крутит пропорциональные лоты, это похоже на искусственный оборот. Идёт на review.

AF-TRADE-032 — time-aligned opposite positions
Если связанные аккаунты почти одновременно открывают противоположные позиции, это hedge-сигнал. Особенно важно рядом с бонусами.

AF-TRADE-033 — sniper hedge
Если противоположные позиции открываются за секунды на разных аккаунтах, это сильный coordinated pattern. Проверяется cluster.

AF-TRADE-034 — cross-broker hedge suspected
Если есть подозрение на hedge через другого брокера, это только soft flag. В одиночку такое почти невозможно доказать.

E. News / pre-news / frozen quote

AF-TRADE-040 — pre-news concentration
Если клиент активно торгует прямо перед важными новостями, это review. Может быть стратегия, а может быть инсайд/эксплуатация.

AF-TRADE-041 — news-window win-rate spike
Если во время новостей резко растёт win-rate, это потенциальный insider/leak сигнал. При escalation возможен compliance/SAR consideration.

AF-TRADE-042 — frozen-quote exploit
Если клиент торгует в окно замороженной котировки после новости, это review. Нужен economic calendar feed.

F. Low-liquidity / manipulation

AF-TRADE-050 — low-liquidity instrument concentration
Если прибыль концентрируется на низколиквидных инструментах, это флаг manipulation/toxic flow. Обычно начинается с review.

AF-TRADE-051 — self-driven price impact
Если размер ордера слишком велик относительно доступной ликвидности LP, клиент может сам двигать цену. Это отправляется в trade-review.

AF-TRADE-052 — coordinated low-liquidity trading
Если hard_cluster координированно торгует низколиквидные инструменты, trading ограничивают. Это второй trading-case с прямым restrict-trading.

AF-TRADE-053 — off-hours trading concentration
Если торговля концентрируется в тихие ночные часы, это soft flag. Может быть легитимно, но повышает риск price manipulation.

G. Execution integrity

AF-TRADE-060 — slippage anomaly
Если клиент системно получает лучшее исполнение, чем должно быть по LP feed, открывается internal incident. Это может быть не клиентский fraud, а проблема execution/bridge.

AF-TRADE-061 — re-quote rate anomaly per LP
Если по конкретному LP аномально много re-quotes, создаётся incident. Это сигнал для Treasury/Risk/IT.

AF-TRADE-062 — order rejection rate per instrument
Если по инструменту слишком много rejected orders, это flag-soft. Может быть техническая проблема или abuse pattern.

H. Internal dealing fraud

AF-TRADE-070 — manual override by dealer
Если dealer вручную вмешался в исполнение ордера, создаётся incident. Это audit trail против внутреннего fraud.

AF-TRADE-071 — same dealer approves VIP orders
Если один dealer постоянно approves сделки одних и тех же VIP-клиентов, это подозрительно. Может быть конфликт интересов.

AF-TRADE-072 — spread / quote manipulation by dealing desk
Если dealing desk манипулирует spread/quotes, создаётся критичный internal incident. Enforcement идёт уже через Internal Fraud domain.

AF-TRADE-073 — selective favorable execution
Если dealer исполняет клиентские ордера выборочно выгодным образом, это incident. Проверяется возможный внутренний сговор.

I. Bot / algo

AF-TRADE-080 — order timing too uniform
Если timing ордеров слишком ровный для человека, это bot signature. Обычно это soft flag.

AF-TRADE-081 — bot-driven volume spike + clustered API calls
Если объём резко растёт вместе с clustered API calls и обходом rate-limit, trading ставится на hold. Это третье trading-rule с прямым client-facing действием.

AF-TRADE-082 — algo trading on retail account
Если algo trading запрещён на retail account type, система ставит soft flag. Работает только если такая политика реально есть в Client Agreement.

J. Gap / exotic / stop-swap

AF-TRADE-090 — gap exploitation
Если клиент зарабатывает в первые 60 секунд после открытия рынка больше статистического порога, это review. Одиночный случай не fraud, повторяемый cluster-pattern опаснее.

AF-TRADE-091 — exotic / tail symbols profit concentration
Если клиент устойчиво зарабатывает в экзотических инструментах, это soft flag. Может быть edge, а может быть эксплуатация плохой ликвидности.

AF-TRADE-092 — stop / swap timing abuse
Если клиент массово открывается перед swap-hour или использует аномальные stop/swap моменты, это review. Проверяется, не эксплуатирует ли он микроструктурную дыру.