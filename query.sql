-- Список видео
select *
from video;

-- Список пользователей
select *
from "user";

-- Количество оценок постов и просмотров видео по пользователям
select u.id, count(v) video_view_count, count(r) reaction_count
from "user" u
       left join reaction r on r.user_id = u.id
       left join video_view v on v.user_id = u.id
where v.deleted_at is null
  and r.deleted_at is null
group by u.id
order by video_view_count desc, reaction_count desc;

-- Количество просмотров, постов и реакций для видео
select v.id, count(view) view_count, count(post) post_count, count(r) reaction_count
from video v
       left join video_view view on v.id = view.video_id
       left join post on post.video_id = v.id
       left join (select distinct r.user_id, post.video_id, r.type
                  from reaction r
                         join post on r.post_id = post.id
                  where r.deleted_at is null) r on r.video_id = v.id
where view.deleted_at is null
group by v.id
order by view_count desc, reaction_count desc, post_count desc;

-- Выгрузка положительных и отрицательных реакций по пользователям
SELECT q.user_id, q.likes, q.dislikes INTO user_reaction
FROM (select u.id user_id, array_agg(distinct r_like.post_id) likes, array_agg(distinct r_dislike.post_id) dislikes
      from "user" u
             left join reaction r_like on u.id = r_like.user_id
             left join reaction r_dislike on u.id = r_dislike.user_id
      where r_like.type = 'like'
        and r_dislike.type = 'dislike'
      group by u.id) q;

-- Фукнция для определения разницы между двумя массивами
CREATE OR REPLACE FUNCTION diff_arr(arr1 int [], arr2 int [])
  RETURNS int [] language sql as
$FUNCTION$
SELECT ARRAY(SELECT UNNEST(arr1)
                 EXCEPT
                 SELECT UNNEST(arr2)
           );
$FUNCTION$;

-- Фукнция для определения количество совпадений между двумя массивами
CREATE OR REPLACE FUNCTION arr_count_matches(arr1 int [], arr2 int [])
  RETURNS int language sql as
$FUNCTION$
SELECT coalesce(array_length((ARRAY(SELECT UNNEST(arr1)
                                        INTERSECT
                                        SELECT UNNEST(arr2)
    )), 1), 0);
$FUNCTION$;

-- Разница между лайками разных пользователей в порядке уменьшения совпадений лайков и дизлайков
select u.id                                                                user_id,
       diff_arr(enother_user_reaction.likes, user_reaction.likes)          likes_diff,
       arr_count_matches(enother_user_reaction.likes, user_reaction.likes) likes_matches,
       arr_count_matches(enother_user_reaction.dislikes, user_reaction.dislikes) dislikes_matches
from "user" u
       join user_reaction on user_reaction.user_id = u.id
       cross join user_reaction enother_user_reaction
where enother_user_reaction.user_id <> u.id
order u.id asc, by likes_matches desc, dislikes_matches desc;