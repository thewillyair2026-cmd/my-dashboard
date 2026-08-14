-- 시차 사용 시 시간을 별도로 기록할 수 있도록 컬럼 추가 (일수는 시간÷8로 자동 환산해 저장)
alter table hr_leave_usage add column if not exists hours numeric;
