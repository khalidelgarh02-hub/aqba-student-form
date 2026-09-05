-- بوابة الأستاذ / استمارة التلميذ
-- مشروع Supabase: jwzebyfhsfszpgswnbyh
-- نفّذ هذا الملف من Supabase SQL Editor.
-- مهم: لا تضع service_role/secret key في GitHub أو داخل HTML.

create extension if not exists pgcrypto;

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  full_name text not null,
  full_name_fr text,
  birth_date date,
  birth_place text,
  address text,
  class_name text,
  other_class text,
  distance text,
  travel_time text,
  father_job text,
  mother_job text,
  current_level text,
  favorite_sport text,
  other_sport text,
  represented boolean,
  competition_name text,
  competition_level text,
  competition_year text,
  competition_sport text,
  height numeric,
  weight numeric,
  health_status text,
  personal_problem text,
  signature_student text,
  signature_teacher text,
  raw_data jsonb
);

alter table public.students enable row level security;

-- إزالة صلاحيات العميل الواسعة القديمة ثم منح أقل صلاحيات لازمة.
revoke all on table public.students from anon, authenticated;

-- التلميذ غير المسجل يمكنه إرسال استمارة فقط.
grant insert on table public.students to anon;

-- الأستاذ بعد تسجيل الدخول يستطيع قراءة وتحديث وحذف السجلات.
grant select, insert, update, delete on table public.students to authenticated;

drop policy if exists "students_public_insert" on public.students;
create policy "students_public_insert"
on public.students
for insert
to anon
with check (
  full_name is not null
  and length(trim(full_name)) >= 2
);

drop policy if exists "teachers_select_students" on public.students;
create policy "teachers_select_students"
on public.students
for select
to authenticated
using (true);

drop policy if exists "teachers_update_students" on public.students;
create policy "teachers_update_students"
on public.students
for update
to authenticated
using (true)
with check (true);

drop policy if exists "teachers_delete_students" on public.students;
create policy "teachers_delete_students"
on public.students
for delete
to authenticated
using (true);

-- تحديث updated_at تلقائيا.
create or replace function public.set_students_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_students_updated_at on public.students;
create trigger trg_students_updated_at
before update on public.students
for each row execute function public.set_students_updated_at();

create index if not exists idx_students_class_name on public.students(class_name);
create index if not exists idx_students_current_level on public.students(current_level);
create index if not exists idx_students_created_at on public.students(created_at desc);

-- أنشئ حساب الأستاذ من:
-- Supabase Dashboard > Authentication > Users > Add user
-- ثم استعمل البريد وكلمة المرور في teacher.html.
