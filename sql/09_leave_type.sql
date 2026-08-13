-- 연차 사용 내역에 구분(연차/반차·시차/월차) 컬럼 추가
alter table hr_leave_usage add column if not exists leave_type text not null default '연차';
