--문제1.
--가장 늦게 입사한 직원의 이름(first_name last_name)과 연봉(salary)과 근무하는 부서
--이름(department_name)은?
--1)rownum 배우기 전
select es.first_name||' '||es.last_name "이름",
        es.salary "연봉",
        ds.department_name "근무부서",
        es.hire_date "입사일"
from employees es, departments ds
where es.department_id = ds.department_id
      and es.hire_date = (select max(hire_date)
                          from employees);

--2)rownum 을 사용한 sql 풀이
select es.first_name||' '||es.last_name "이름",
            es.salary "연봉",
            ds.department_name "근무부서",
            es.hire_date "입사일"
from employees es, departments ds
where es.department_id = ds.department_id
      and es.hire_date =  (select b.hire_date
                           from
                               (select rownum,
                                     a.hire_date
                                from
                                    (select hire_date
                                     from employees
                                     order by hire_date desc
                                    ) a
                                where rownum = 1
                                )b 
                          );   -- 이 문제에서는 비효율 적인듯 바로 테이블에서 최대값을 뽑을수 있기 때문에


--문제2.
--평균연봉(salary)이 가장 높은 부서 직원들의 직원번호(employee_id), 이름(firt_name),
--성(last_name)과 업무(job_title), 연봉(salary)을 조회하시오.
--1)rownum 배우기 전
select es.employee_id "사원번호",
        es.first_name||' '||es.last_name "이름",
        js.job_title "업무명",
        es.salary "연봉"
from employees es, jobs js
where es.job_id = js.job_id 
      and es.department_id = (select department_id
                              from (select department_id,
                                         avg(salary) avgSalary
                                    from employees
                                    group by department_id) avgs
                              where avgs.avgSalary = (select max(avg(salary))
                                                     from employees
                                                     group by department_id));
                                                     
--2)rownum 을 사용한 sql 풀이
select ds.department_name,
        es.employee_id "사번",
        es.first_name||' '||es.last_name "이름",
        js.job_title "업무명",
        es.salary "연봉"
from employees es, jobs js , departments ds
where es.job_id = js.job_id
      and es.department_id = ds.department_id
      and ds.department_name =
                        (select a.department_name
                        from (select  rownum,
                                        department_name
                                from 
                                    (select ds.department_name,
                                            avg(es.salary) "평균급여"
                                    from employees es, departments ds
                                    where es.department_id = ds.department_id
                                    group by ds.department_name
                                    order by "평균급여" desc
                                    ) avgs
                                where rownum = 1
                             )a
                        );
                                        
                                                     
--문제3.
--평균 급여(salary)가 가장 높은 부서는?
--1)rownum 배우기 전
select distinct ds.department_name "부서명"
from employees es,
     departments ds,
     (select department_id,
             avg(salary) avgSalary
      from employees
      group by department_id) avgs
where es.department_id = ds.department_id
      and es.department_id = avgs.department_id
      and avgs.avgSalary = (select max(avg(salary))
                            from employees
                            group by department_id);
                            
--2)rownum 을 사용한 sql 풀이
select r."부서명"
from
    (select rownum,
            avgs."부서명",
            avgs."평균급여"
    from
        (select department_name "부서명",
               avg(salary) "평균급여"
        from employees es,
             departments ds
        where es.department_id = ds.department_id
        group by department_name
        order by "평균급여" desc
        ) avgs
    where rownum = 1    --where 절에서는 현재 select 문에 붙여놓은 별칭을 사용 할 수 없는것 같음...
                         --별칭은 다음 select문에서 사용하기 위해서 붙이는 이름인듯...
    )r;



--문제4.
--평균 급여(salary)가 가장 높은 지역은?

select "지역명"
--1)rownum 배우기 전
from (select rs.region_name "지역명",
                avg(es.salary) avgSalary
        from employees es,
             departments ds,
             locations ls,
             countries cs,
             regions rs
        where es.department_id = ds.department_id
              and ds.location_id = ls.location_id
              and ls.country_id = cs.country_id
              and cs.region_id = rs.region_id
        group by rs.region_name) avgs
where avgs.avgSalary = (select max(avg(es.salary))
                       from employees es,
                             departments ds,
                             locations ls,
                             countries cs,
                             regions rs
                       where es.department_id = ds.department_id
                             and ds.location_id = ls.location_id
                             and ls.country_id = cs.country_id
                             and cs.region_id = rs.region_id
                       group by rs.region_name);
                       
--2)rownum 을 사용한 sql 풀이
select totalResult."지역명"
from
    (select rownum rn,
            "지역명"
     from 
           (select  rs.region_name "지역명",
                 avg(es.salary) avgSalary
            from employees es,
                 departments ds,
                 locations ls,
                 countries cs,
                 regions rs
            where es.department_id = ds.department_id
                  and ds.location_id = ls.location_id
                  and ls.country_id = cs.country_id
                  and cs.region_id = rs.region_id
            group by rs.region_name
            order by avgSalary desc
            ) avgs
     ) totalResult
where totalResult.rn = 1;


--문제5.
--평균 급여(salary)가 가장 높은 업무는?
--1)rownum 배우기 전
select j.job_title
from
     (select js.job_id,
             avg(es.salary) avgsalary
      from employees es, jobs js
      where es.job_id = js.job_id
      group by js.job_id) jes ,jobs j 
where jes.job_id = j.job_id
      and jes.avgsalary = (select max(avg(es.salary)) avgsalary
                           from employees es, jobs js
                           where es.job_id = js.job_id
                           group by js.job_id);

--2)rownum 을 사용한 sql 풀이
select job_title
from
     (select rownum rn,
               job_title
     from (select job_title,
                  avg(salary) avgSalary
           from employees es , jobs js
           where es.job_id = js.job_id
           group by job_title
           order by avgSalary desc
           ) r
     ) r2
where r2.rn= 1;

