-- ============================================================
-- MediHub Database Schema
-- Run this entire file in Supabase: Dashboard → SQL Editor → New query
-- ============================================================

-- ── USERS ────────────────────────────────────────────────────
create table if not exists public.users (
  id           uuid primary key references auth.users(id) on delete cascade,
  name         text not null,
  email        text not null,
  phone        text default '',
  photo_url    text,
  role         text default 'patient' check (role in ('patient', 'provider', 'admin')),
  created_at   timestamptz default now()
);

alter table public.users enable row level security;

create policy "Users can read own data"
  on public.users for select using (auth.uid() = id);

create policy "Users can update own data"
  on public.users for update using (auth.uid() = id);

create policy "Users can insert own data"
  on public.users for insert with check (auth.uid() = id);

-- ── HOSPITALS ─────────────────────────────────────────────────
create table if not exists public.hospitals (
  id           bigint primary key generated always as identity,
  name         text not null,
  address      text not null,
  lat          double precision not null,
  lng          double precision not null,
  services     text default '',
  phone        text default '',
  email        text default '',
  hours        text default '',
  rating       double precision default 0,
  review_count int default 0,
  photo_url    text,
  type         text default 'clinic' check (type in ('hospital', 'clinic')),
  is_verified  boolean default false,
  created_at   timestamptz default now()
);

alter table public.hospitals enable row level security;

create policy "Anyone can read hospitals"
  on public.hospitals for select using (true);

create policy "Only admins can insert hospitals"
  on public.hospitals for insert with check (
    exists (
      select 1 from public.users
      where id = auth.uid() and role in ('admin', 'provider')
    )
  );

-- ── DOCTORS ───────────────────────────────────────────────────
create table if not exists public.doctors (
  id                bigint primary key generated always as identity,
  hospital_id       bigint references public.hospitals(id) on delete cascade,
  name              text not null,
  specialty         text not null,
  bio               text default '',
  consultation_fee  double precision default 0,
  photo_url         text,
  rating            double precision default 0,
  review_count      int default 0,
  available_days    text default '',
  start_time        text default '08:00',
  end_time          text default '17:00',
  slot_duration     int default 30,
  created_at        timestamptz default now()
);

alter table public.doctors enable row level security;

create policy "Anyone can read doctors"
  on public.doctors for select using (true);

-- ── APPOINTMENTS ──────────────────────────────────────────────
create table if not exists public.appointments (
  id                 bigint primary key generated always as identity,
  patient_id         uuid references public.users(id) on delete cascade,
  patient_name       text not null,
  doctor_id          bigint references public.doctors(id),
  doctor_name        text not null,
  doctor_specialty   text default '',
  hospital_id        bigint references public.hospitals(id),
  hospital_name      text not null,
  date               date not null,
  time_slot          text not null,
  status             text default 'pending'
                       check (status in ('pending','approved','completed','cancelled')),
  notes              text,
  document_urls      text default '',
  consultation_fee   double precision default 0,
  created_at         timestamptz default now()
);

alter table public.appointments enable row level security;

create policy "Patients can read own appointments"
  on public.appointments for select
  using (auth.uid() = patient_id);

create policy "Providers can read their hospital appointments"
  on public.appointments for select
  using (
    exists (
      select 1 from public.users
      where id = auth.uid() and role = 'provider'
    )
  );

create policy "Patients can create appointments"
  on public.appointments for insert
  with check (auth.uid() = patient_id);

create policy "Patients can update own appointments"
  on public.appointments for update
  using (auth.uid() = patient_id);

create policy "Providers can update appointment status"
  on public.appointments for update
  using (
    exists (
      select 1 from public.users
      where id = auth.uid() and role in ('provider', 'admin')
    )
  );

-- ── REVIEWS ───────────────────────────────────────────────────
create table if not exists public.reviews (
  id           bigint primary key generated always as identity,
  patient_id   uuid references public.users(id),
  patient_name text not null,
  doctor_id    bigint references public.doctors(id),
  hospital_id  bigint references public.hospitals(id),
  rating       double precision not null check (rating >= 1 and rating <= 5),
  comment      text default '',
  created_at   timestamptz default now()
);

alter table public.reviews enable row level security;

create policy "Anyone can read reviews"
  on public.reviews for select using (true);

create policy "Patients can create reviews"
  on public.reviews for insert
  with check (auth.uid() = patient_id);

-- ── CHATS ─────────────────────────────────────────────────────
create table if not exists public.chats (
  id                bigint primary key generated always as identity,
  user1_id          uuid references public.users(id),
  user1_name        text not null,
  user2_id          uuid references public.users(id),
  user2_name        text not null,
  last_message      text default '',
  last_message_time timestamptz default now(),
  created_at        timestamptz default now()
);

alter table public.chats enable row level security;

create policy "Chat participants can read their chats"
  on public.chats for select
  using (auth.uid() = user1_id or auth.uid() = user2_id);

create policy "Authenticated users can create chats"
  on public.chats for insert
  with check (auth.uid() = user1_id or auth.uid() = user2_id);

create policy "Chat participants can update chat"
  on public.chats for update
  using (auth.uid() = user1_id or auth.uid() = user2_id);

-- ── MESSAGES ──────────────────────────────────────────────────
create table if not exists public.messages (
  id           bigint primary key generated always as identity,
  chat_id      bigint references public.chats(id) on delete cascade,
  sender_id    uuid references public.users(id),
  sender_name  text not null,
  text         text not null,
  is_read      boolean default false,
  created_at   timestamptz default now()
);

alter table public.messages enable row level security;

create policy "Chat participants can read messages"
  on public.messages for select
  using (
    exists (
      select 1 from public.chats
      where id = chat_id
        and (user1_id = auth.uid() or user2_id = auth.uid())
    )
  );

create policy "Authenticated users can send messages"
  on public.messages for insert
  with check (auth.uid() = sender_id);

-- ── NOTIFICATIONS ─────────────────────────────────────────────
create table if not exists public.notifications (
  id           bigint primary key generated always as identity,
  user_id      uuid references public.users(id) on delete cascade,
  title        text not null,
  body         text not null,
  type         text default 'system',
  is_read      boolean default false,
  reference_id text,
  created_at   timestamptz default now()
);

alter table public.notifications enable row level security;

create policy "Users can read own notifications"
  on public.notifications for select
  using (auth.uid() = user_id);

create policy "Users can update own notifications"
  on public.notifications for update
  using (auth.uid() = user_id);

-- Service role can insert notifications (from backend/functions)
create policy "Service role can insert notifications"
  on public.notifications for insert
  with check (true);

-- ── SEED DATA ─────────────────────────────────────────────────
-- Sample hospitals (Las Piñas / Metro Manila area)
insert into public.hospitals (name, address, lat, lng, services, phone, email, hours, rating, review_count, type, is_verified)
values
  ('St. Luke''s Medical Center - BGC', 'Rizal Drive, Taguig City, Metro Manila',
   14.5500, 121.0484,
   'Emergency,Cardiology,Pediatrics,OB-GYN,Surgery,Neurology',
   '+63 2 8789 7700', 'info@stlukes.com.ph',
   'Mon-Sun: Open 24 Hours', 4.7, 0, 'hospital', true),

  ('Las Piñas General Hospital', 'Talon Dos, Las Piñas City, Metro Manila',
   14.4497, 121.0003,
   'General Medicine,Pediatrics,Emergency,Laboratory,Radiology',
   '+63 2 8805 2000', 'lpgh@health.gov.ph',
   'Mon-Sun: Open 24 Hours', 4.2, 0, 'hospital', true),

  ('Family Care Clinic - BF Homes', 'BF Homes, Las Piñas City, Metro Manila',
   14.4386, 121.0071,
   'General Medicine,Dentistry,Eye Care,Vaccination',
   '+63 2 8874 3210', 'familycare@clinic.ph',
   'Mon-Sat: 8AM-6PM', 4.5, 0, 'clinic', true),

  ('Ospital ng Las Piñas', 'Pamplona III, Las Piñas City, Metro Manila',
   14.4445, 121.0035,
   'Emergency,Internal Medicine,Pediatrics,OB-GYN,Surgery',
   '+63 2 8872 0000', 'onlp@health.gov.ph',
   'Mon-Sun: Open 24 Hours', 4.0, 0, 'hospital', true);

-- Sample doctors for hospital id=1
insert into public.doctors (hospital_id, name, specialty, bio, consultation_fee, rating, review_count, available_days, start_time, end_time, slot_duration)
values
  (1, 'Dr. Maria Santos',    'Internal Medicine',
   'Board-certified internist with 12 years of experience.',
   800, 4.8, 0, 'Mon,Tue,Wed,Thu,Fri', '09:00', '17:00', 30),

  (1, 'Dr. James Reyes',     'Pediatrics',
   'Dedicated pediatrician focused on child health from newborns to adolescents.',
   700, 4.9, 0, 'Mon,Wed,Fri', '08:00', '15:00', 30),

  (1, 'Dr. Ana Flores',      'OB-GYN',
   'Specialist in women''s health, prenatal care, and reproductive medicine.',
   1000, 4.7, 0, 'Tue,Thu,Sat', '10:00', '16:00', 45);

-- Sample doctors for hospital id=2
insert into public.doctors (hospital_id, name, specialty, bio, consultation_fee, rating, review_count, available_days, start_time, end_time, slot_duration)
values
  (2, 'Dr. Ramon Cruz',      'General Medicine',
   'Experienced general practitioner handling a wide range of medical concerns.',
   600, 4.5, 0, 'Mon,Tue,Wed,Thu,Fri', '08:00', '17:00', 30),

  (2, 'Dr. Liza Mendoza',    'Pediatrics',
   'Caring pediatrician with a gentle approach to child healthcare.',
   650, 4.6, 0, 'Mon,Wed,Fri,Sat', '09:00', '16:00', 30);

-- Sample doctors for hospital id=3
insert into public.doctors (hospital_id, name, specialty, bio, consultation_fee, rating, review_count, available_days, start_time, end_time, slot_duration)
values
  (3, 'Dr. Carlo Bautista',  'General Medicine',
   'Family doctor committed to preventive care and overall wellness.',
   500, 4.4, 0, 'Mon,Tue,Thu,Fri', '08:30', '17:30', 30),

  (3, 'Dr. Grace Villanueva','Dentistry',
   'Gentle dentist specializing in cosmetic and restorative dental care.',
   800, 4.8, 0, 'Tue,Thu,Sat', '09:00', '17:00', 60);

-- Sample doctors for hospital id=4
insert into public.doctors (hospital_id, name, specialty, bio, consultation_fee, rating, review_count, available_days, start_time, end_time, slot_duration)
values
  (4, 'Dr. Eduardo Pascual', 'Surgery',
   'Board-certified surgeon with expertise in laparoscopic procedures.',
   1200, 4.6, 0, 'Mon,Tue,Wed', '07:00', '14:00', 60),

  (4, 'Dr. Sheila Aquino',   'OB-GYN',
   'Compassionate OB-GYN with extensive experience in maternal-fetal medicine.',
   900, 4.7, 0, 'Wed,Thu,Fri', '10:00', '17:00', 45);
