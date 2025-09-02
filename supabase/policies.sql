-- Enable RLS and add policies
-- profiles
alter table public.profiles enable row level security;
create policy profiles_read on public.profiles for
select using (true);
create policy profiles_insert on public.profiles for
insert with check (auth.uid() = id);
create policy profiles_update on public.profiles for
update using (auth.uid() = id) with check (auth.uid() = id);
-- news_items
alter table public.news_items enable row level security;
create policy news_read on public.news_items for
select using (true);
-- no insert/update/delete policy for anon users (service key only)
-- posts
alter table public.posts enable row level security;
create policy posts_read on public.posts for
select using (true);
create policy posts_insert on public.posts for
insert with check (
        auth.role() = 'authenticated'
        and auth.uid() = author_id
    );
-- forbid update/delete
-- answers
alter table public.answers enable row level security;
create policy answers_read on public.answers for
select using (true);
create policy answers_insert on public.answers for
insert with check (
        auth.role() = 'authenticated'
        and auth.uid() = author_id
    );
-- comments
alter table public.comments enable row level security;
create policy comments_read on public.comments for
select using (true);
create policy comments_insert on public.comments for
insert with check (
        auth.role() = 'authenticated'
        and auth.uid() = author_id
    );
-- likes
alter table public.likes enable row level security;
create policy likes_read on public.likes for
select using (true);
create policy likes_insert on public.likes for
insert with check (
        auth.role() = 'authenticated'
        and auth.uid() = user_id
    );
create policy likes_delete on public.likes for delete using (auth.uid() = user_id);
-- favorites
alter table public.favorites enable row level security;
create policy favorites_read on public.favorites for
select using (true);
create policy favorites_insert on public.favorites for
insert with check (
        auth.role() = 'authenticated'
        and auth.uid() = user_id
    );
-- no delete policy
-- reports
alter table public.reports enable row level security;
create policy reports_insert on public.reports for
insert with check (
        auth.role() = 'authenticated'
        and auth.uid() = user_id
    );
create policy reports_read_own on public.reports for
select using (auth.uid() = user_id);
-- views
alter table public.views enable row level security;
create policy views_insert on public.views for
insert with check (true);
create policy views_select_agg on public.views for
select using (true);
-- points_log
alter table public.points_log enable row level security;
create policy points_log_read_own on public.points_log for
select using (auth.uid() = user_id);
-- inserts via function/trigger only
-- messages
alter table public.messages enable row level security;
create policy messages_read_participants on public.messages for
select using (auth.uid() in (sender_id, receiver_id));
create policy messages_insert_sender on public.messages for
insert with check (auth.uid() = sender_id);
create policy messages_update_receiver_read on public.messages for
update using (auth.uid() = receiver_id) with check (auth.uid() = receiver_id);
-- no delete
-- notifications
alter table public.notifications enable row level security;
create policy notifications_read_own on public.notifications for
select using (auth.uid() = user_id);
create policy notifications_update_own on public.notifications for
update using (auth.uid() = user_id) with check (auth.uid() = user_id);
-- inserts via triggers
-- feedbacks
alter table public.feedbacks enable row level security;
create policy feedbacks_read_own on public.feedbacks for
select using (auth.uid() = user_id);
create policy feedbacks_insert on public.feedbacks for
insert with check (true);
-- no delete
-- sensitive_words
alter table public.sensitive_words enable row level security;
create policy sensitive_words_read on public.sensitive_words for
select using (true);
-- updates/inserts restricted to service role only
-- crawler_logs
alter table public.crawler_logs enable row level security;
create policy crawler_logs_read on public.crawler_logs for
select using (true);
-- inserts via function/service only