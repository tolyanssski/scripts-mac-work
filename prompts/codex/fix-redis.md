Нужно во все проекты в папке $HOME/projects, названия которых начинаются на br- (кроме br-contracts, br-sdk), которые работают с Redis, внести правку подключения к редису,
чтобы было вот так (новый параметр ConnMaxLifetime):


redisClient := redis.NewFailoverClient(&redis.FailoverOptions{
    MasterName:      redisName,
    SentinelAddrs:   redisAddrs,
    Password:        redisPassword,
    ConnMaxLifetime: 30 * time.Minute,
  })
