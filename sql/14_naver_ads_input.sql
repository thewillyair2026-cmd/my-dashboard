-- 네이버 유료광고(파워링크·쇼핑검색) 월별 입력 허용: 같은 연월+상품으로 다시 저장하면 덮어쓰도록 유니크 키를 추가하고,
-- owner·marketing 역할만 쓸 수 있는 쓰기 정책을 추가합니다. 기존 데이터는 그대로 유지됩니다(다시 실행해도 안전).
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'marketing_naver_ads_month_product_key') then
    alter table marketing_naver_ads add constraint marketing_naver_ads_month_product_key unique (month, product);
  end if;
end $$;
drop policy if exists "write" on marketing_naver_ads;
create policy "write" on marketing_naver_ads for all to authenticated
  using (has_role(array['owner','marketing']))
  with check (has_role(array['owner','marketing']));
