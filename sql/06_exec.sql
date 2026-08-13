-- 경영 대시보드 (WILLY 버전) — 목표값을 실제 규모에 맞게 조정했습니다.
-- 앞의 5개(영업/마케팅/고객/손익/인사) 표를 그대로 불러다 씁니다. 반드시 마지막에 실행하세요.

drop table if exists exec_target;

create table exec_target (
  id bigint primary key generated always as identity,
  sort_order int not null, area text not null,
  target numeric not null, green numeric not null, yellow numeric not null
);
insert into exec_target (sort_order, area, target, green, yellow) values
  (1,'매출',     9200, 90, 80),
  (2,'ROAS',     400,  100, 85),
  (3,'신규고객', 200,  95, 85),
  (4,'영업이익', 950,  90, 75),
  (5,'인건비율', 25,   95, 85);

alter table exec_target enable row level security;
create policy "read" on exec_target for select to anon using (true);
