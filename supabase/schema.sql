-- Schema for AI Programming News & Community
-- Enable extensions
create extension if not exists pgcrypto;
-- profiles
create table if not exists public.profiles (
  id uuid primary key,
  username text unique,
  avatar_url text,
  bio text,
  points integer not null default 0,
  level integer not null default 1,
  created_at timestamptz not null default now(),
  updated_at timestamptz
);
-- news_items
create table if not exists public.news_items (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  url text not null,
  source text not null,
  published_at timestamptz,
  summary text,
  author text,
  image_url text,
  tags text [],
  content_html text,
  hash text not null unique,
  created_at timestamptz not null default now()
);
create index if not exists idx_news_items_published_at on public.news_items(published_at desc);
create index if not exists idx_news_items_source_date on public.news_items(source, published_at desc);
-- posts (forum/question)
create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references public.profiles(id) on delete restrict,
  type text not null check (type in ('post', 'question')),
  title text not null,
  content text not null,
  media jsonb not null default '[]'::jsonb,
  category text,
  like_count integer not null default 0,
  comment_count integer not null default 0,
  view_count integer not null default 0,
  updated_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);
create index if not exists idx_posts_author on public.posts(author_id);
create index if not exists idx_posts_created on public.posts(created_at desc);
create index if not exists idx_posts_type_created on public.posts(type, created_at desc);
create index if not exists idx_posts_category on public.posts(category);
create index if not exists idx_posts_title_search on public.posts using gin(to_tsvector('english', title));
-- answers (to questions)
create table if not exists public.answers (
  id uuid primary key default gen_random_uuid(),
  question_id uuid not null references public.posts(id) on delete restrict,
  author_id uuid not null references public.profiles(id) on delete restrict,
  content text not null,
  media jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists idx_answers_question on public.answers(question_id);
-- comments (single-level)
create table if not exists public.comments (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null check (entity_type in ('news', 'post', 'answer')),
  entity_id uuid not null,
  author_id uuid not null references public.profiles(id) on delete restrict,
  content text not null,
  created_at timestamptz not null default now()
);
create index if not exists idx_comments_entity on public.comments(entity_type, entity_id);
-- likes (toggle allowed)
create table if not exists public.likes (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null check (entity_type in ('news', 'post', 'answer')),
  entity_id uuid not null,
  user_id uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (entity_type, entity_id, user_id)
);
create index if not exists idx_likes_user on public.likes(user_id);
-- favorites (no delete by user)
create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null check (entity_type in ('news', 'post', 'answer')),
  entity_id uuid not null,
  user_id uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (entity_type, entity_id, user_id)
);
create index if not exists idx_favorites_user on public.favorites(user_id);
-- reports
create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null check (
    entity_type in ('news', 'post', 'answer', 'comment')
  ),
  entity_id uuid not null,
  user_id uuid not null references public.profiles(id) on delete restrict,
  reason text not null,
  created_at timestamptz not null default now()
);
-- views
create table if not exists public.views (
  id bigint generated always as identity primary key,
  entity_type text not null check (entity_type in ('news', 'post', 'answer')),
  entity_id uuid not null,
  viewer_id uuid references public.profiles(id) on delete
  set null,
    viewed_at timestamptz not null default now()
);
create index if not exists idx_views_entity on public.views(entity_type, entity_id);
-- points log
create table if not exists public.points_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete restrict,
  action text not null,
  delta integer not null,
  created_at timestamptz not null default now()
);
create index if not exists idx_points_log_user on public.points_log(user_id, created_at desc);
-- messages (direct messages)
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles(id) on delete restrict,
  receiver_id uuid not null references public.profiles(id) on delete restrict,
  content text not null,
  created_at timestamptz not null default now(),
  read boolean not null default false
);
create index if not exists idx_messages_users on public.messages(sender_id, receiver_id, created_at desc);
-- notifications
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete restrict,
  type text not null,
  payload jsonb not null,
  created_at timestamptz not null default now(),
  read boolean not null default false
);
create index if not exists idx_notifications_user on public.notifications(user_id, created_at desc);
-- feedbacks
create table if not exists public.feedbacks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete
  set null,
    content text not null,
    files jsonb not null default '[]'::jsonb,
    created_at timestamptz not null default now()
);
create index if not exists idx_feedbacks_user on public.feedbacks(user_id, created_at desc);
-- sensitive words
create table if not exists public.sensitive_words (
  id uuid primary key default gen_random_uuid(),
  word text unique not null,
  created_at timestamptz not null default now()
);
-- crawler logs
create table if not exists public.crawler_logs (
  id uuid primary key default gen_random_uuid(),
  source text not null,
  status text not null,
  message text,
  created_at timestamptz not null default now()
);