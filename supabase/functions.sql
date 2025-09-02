-- Functions & Triggers

-- sensitive words check function
create or replace function public.fn_check_sensitive(p_text text)
returns boolean
language plpgsql
security definer
as $$
declare
  w text;
begin
  if p_text is null then
    return true;
  end if;
  for w in select word from public.sensitive_words loop
    if position(lower(w) in lower(p_text)) > 0 then
      return false;
    end if;
  end loop;
  return true;
end;
$$;

-- trigger to block sensitive content
create or replace function public.trg_block_sensitive()
returns trigger
language plpgsql
as $$
begin
  if TG_TABLE_NAME = 'posts' then
    if not public.fn_check_sensitive(NEW.title) or not public.fn_check_sensitive(NEW.content) then
      raise exception '内容包含敏感词，已被拒绝';
    end if;
  elsif TG_TABLE_NAME = 'answers' then
    if not public.fn_check_sensitive(NEW.content) then
      raise exception '内容包含敏感词，已被拒绝';
    end if;
  elsif TG_TABLE_NAME = 'comments' then
    if not public.fn_check_sensitive(NEW.content) then
      raise exception '内容包含敏感词，已被拒绝';
    end if;
  end if;
  return NEW;
end;
$$;

create trigger before_posts_sensitive
before insert or update on public.posts
for each row execute function public.trg_block_sensitive();

create trigger before_answers_sensitive
before insert or update on public.answers
for each row execute function public.trg_block_sensitive();

create trigger before_comments_sensitive
before insert or update on public.comments
for each row execute function public.trg_block_sensitive();

-- award points
create or replace function public.fn_award_points(p_user uuid, p_action text, p_delta int)
returns void
language plpgsql
security definer
as $$
begin
  insert into public.points_log(user_id, action, delta) values (p_user, p_action, p_delta);
  update public.profiles set points = points + p_delta where id = p_user;
  perform public.fn_recalc_level(p_user);
end;
$$;

-- recalc level
create or replace function public.fn_recalc_level(p_user uuid)
returns void
language plpgsql
security definer
as $$
declare
  p int;
  lvl int := 1;
begin
  select points into p from public.profiles where id = p_user;
  if p is null then return; end if;
  if p >= 1000 then lvl := 5;
  elsif p >= 400 then lvl := 4;
  elsif p >= 150 then lvl := 3;
  elsif p >= 50 then lvl := 2;
  else lvl := 1;
  end if;
  update public.profiles set level = lvl where id = p_user;
end;
$$;

-- daily login once
create or replace function public.fn_daily_login()
returns void
language plpgsql
security definer
as $$
begin
  if exists (
    select 1 from public.points_log
    where user_id = auth.uid() and action = 'daily_login' and created_at::date = now()::date
  ) then
    return;
  end if;
  perform public.fn_award_points(auth.uid(), 'daily_login', 5);
end;
$$;

-- after insert hooks to award points
create or replace function public.trg_points_after_insert()
returns trigger
language plpgsql
as $$
begin
  if TG_TABLE_NAME = 'posts' then
    perform public.fn_award_points(NEW.author_id, 'create_post', 10);
  elsif TG_TABLE_NAME = 'comments' then
    perform public.fn_award_points(NEW.author_id, 'create_comment', 2);
  elsif TG_TABLE_NAME = 'likes' then
    -- give +1 to target author (if we can resolve)
    if NEW.entity_type = 'post' then
      perform public.fn_award_points((select author_id from public.posts where id = NEW.entity_id), 'got_liked', 1);
    elsif NEW.entity_type = 'answer' then
      perform public.fn_award_points((select author_id from public.answers where id = NEW.entity_id), 'got_liked', 1);
    end if;
  elsif TG_TABLE_NAME = 'favorites' then
    perform public.fn_award_points(NEW.user_id, 'favorite', 1);
  end if;
  return NEW;
end;
$$;

create trigger after_posts_points
after insert on public.posts
for each row execute function public.trg_points_after_insert();

create trigger after_comments_points
after insert on public.comments
for each row execute function public.trg_points_after_insert();

create trigger after_likes_points
after insert on public.likes
for each row execute function public.trg_points_after_insert();

create trigger after_favorites_points
after insert on public.favorites
for each row execute function public.trg_points_after_insert();

-- increment view
create or replace function public.fn_increment_view(p_entity_type text, p_entity_id uuid)
returns void
language sql
security definer
as $$
  insert into public.views(entity_type, entity_id, viewer_id) values (p_entity_type, p_entity_id, auth.uid());
$$;

-- notifications on interactions
create or replace function public.trg_notify()
returns trigger
language plpgsql
as $$
declare
  target_user uuid;
  payload jsonb;
begin
  if TG_TABLE_NAME = 'answers' then
    select author_id into target_user from public.posts where id = NEW.question_id; -- notify question author
    payload := jsonb_build_object('type','answer','id', NEW.id);
  elsif TG_TABLE_NAME = 'comments' then
    if NEW.entity_type = 'post' then
      select author_id into target_user from public.posts where id = NEW.entity_id;
    elsif NEW.entity_type = 'answer' then
      select author_id into target_user from public.answers where id = NEW.entity_id;
    elsif NEW.entity_type = 'news' then
      target_user := null; -- news 无特定作者
    end if;
    payload := jsonb_build_object('type','comment','id', NEW.id);
  elsif TG_TABLE_NAME = 'likes' then
    if NEW.entity_type = 'post' then
      select author_id into target_user from public.posts where id = NEW.entity_id;
    elsif NEW.entity_type = 'answer' then
      select author_id into target_user from public.answers where id = NEW.entity_id;
    end if;
    payload := jsonb_build_object('type','like','id', NEW.id);
  end if;
  if target_user is not null and target_user <> NEW.user_id then
    insert into public.notifications(user_id, type, payload) values (target_user, TG_TABLE_NAME, payload);
  end if;
  return NEW;
end;
$$;

create trigger after_answers_notify
after insert on public.answers
for each row execute function public.trg_notify();

create trigger after_comments_notify
after insert on public.comments
for each row execute function public.trg_notify();

create trigger after_likes_notify
after insert on public.likes
for each row execute function public.trg_notify();
