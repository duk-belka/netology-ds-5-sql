# Database schema

Данная тестовая база данных представляет из себя упрощенную модель многопользовательского сервиса для обмена и просмотра видео.

## Tables
### User
```postgresql
create table "user"
(
  id         serial       not null
    constraint user_pkey
    primary key,
  updated_at timestamp(0) not null,
  created_at timestamp(0) not null
);
```

### Post
Каждое новое расшаренное видео создает Пост с пользовательским заголовком
```postgresql
create table post
(
  id         serial       not null
    constraint post_pkey
    primary key,
  title      varchar(255) not null,
  video_id   integer      not null,
  updated_at timestamp(0) not null,
  created_at timestamp(0) not null
);
```

### Video
Объект уникального видео с ссылкой на источник.
```postgresql
create table video
(
  id         serial       not null
    constraint file_pkey
    primary key,
  url        varchar(255) not null,
  updated_at timestamp(0) not null,
  created_at timestamp(0) not null
);
```
Может быть много дублирующих друг друга видео.

### VideoView
Сущность просмора видео
```postgresql
create table video_view
(
  video_id   integer      not null,
  user_id    integer      not null,
  created_at timestamp(0) not null,
  deleted_at timestamp(0)
);
```

### Reaction
Реакция пользователя на пост.

```postgresql
create table reaction
(
  post_id    integer      not null,
  user_id    integer      not null,
  type       varchar(255) not null, -- like/dislike
  created_at timestamp(0) not null,
  deleted_at timestamp(0)
);
```