Нужно создать новую ent-сущность PartnershipDeal.

В ней должны быть следующие поля: 
ID (uuid), Time (DateTime), PartnershipReferralID (uuid), 
далее все поля из dto.DealClosedEvent,
далее следующие поля:
CommissionBase (float64),
CommissionReward (float64),
SpreadBase (float64),
SpreadReward (float64),
CreatedAt, UpdatedAt, DeletedAt.

Для этой сущности также сгенерируй SQL-миграцию для Postgresql, скрипт миграции
положи в папку migrations.

Сгенерируй методы репозитория для этой сущности, реализующие стандартные
CRUD-операции.

Сгенерируй DTO-структуру, поля которой повторяют поля этой новой сущности.

Нигде не добавляй никаких foreigh keys и никаких новых edges, 
даже если такое добавление кажется логичным.