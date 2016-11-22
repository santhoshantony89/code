-- many metrics in one query (Oracle version)
SELECT *
FROM
  (
  SELECT 10 AS Position, 'Deployments' AS Metric, COUNT(*) AS Count FROM ACT_RE_DEPLOYMENT
  UNION SELECT 11, 'Process Definitions', COUNT(*) FROM (SELECT DISTINCT KEY_ FROM ACT_RE_PROCDEF) AS PROCDEF
  UNION SELECT 12, 'Process Definition Versions', COUNT(*) FROM ACT_RE_PROCDEF
  UNION SELECT 20, 'Activity Instances', COUNT(*) FROM ACT_HI_ACTINST
  UNION SELECT 21, 'Process Instances', COUNT(*) FROM ACT_HI_PROCINST
  UNION SELECT 22, 'Process Instances (finished)', COUNT(*) FROM ACT_HI_PROCINST WHERE END_TIME_ IS NOT NULL
  UNION SELECT 30, 'Process Instances (running)', COUNT(*) FROM ACT_RU_EXECUTION WHERE PARENT_ID_ IS NULL
  UNION SELECT 30.1, 'Executions (running)', COUNT(*) FROM ACT_RU_EXECUTION
  UNION SELECT 31, 'User Tasks', COUNT(*) FROM ACT_RU_TASK
  UNION SELECT 32, 'User Tasks (unassigned)', COUNT(*) FROM ACT_RU_TASK WHERE ASSIGNEE_ IS NULL
  UNION SELECT 40, 'Event Subscriptions', COUNT(*) FROM ACT_RU_EVENT_SUBSCR
  UNION SELECT 41, 'Event Subscriptions (type: ' || TO_CHAR(EVENT_TYPE_) ||
    DECODE (PROC_INST_ID_, NULL, ' start', ' intermediate') || ')',
    COUNT(*) FROM ACT_RU_EVENT_SUBSCR
    GROUP BY TO_CHAR(EVENT_TYPE_), DECODE (PROC_INST_ID_, NULL, ' start', ' intermediate')
  UNION SELECT 50, 'Jobs', COUNT(*) FROM ACT_RU_JOB
  UNION SELECT 51, 'Jobs (running)', COUNT(*) FROM ACT_RU_JOB
    WHERE (LOCK_OWNER_ IS NOT NULL AND LOCK_EXP_TIME_ >= SYSDATE)
  UNION SELECT 51.0, 'Jobs (running, node=' || LOCK_OWNER_ || ')', COUNT(*) FROM ACT_RU_JOB
    WHERE (LOCK_OWNER_ IS NOT NULL AND LOCK_EXP_TIME_ >= SYSDATE)
    GROUP BY LOCK_OWNER_
  UNION SELECT 51.1, 'Jobs (running at prio: ' || PRIORITY_ || ')', COUNT(*)  FROM ACT_RU_JOB
    WHERE (LOCK_OWNER_ IS NOT NULL AND LOCK_EXP_TIME_ >= SYSDATE)
    GROUP BY PRIORITY_
  UNION SELECT 52, 'Jobs (due)', COUNT(*) FROM ACT_RU_JOB
    WHERE (RETRIES_ > 0)
    AND (DUEDATE_ IS NULL OR DUEDATE_ < SYSDATE)
    AND (LOCK_OWNER_ IS NULL OR LOCK_EXP_TIME_ < SYSDATE)
    AND (SUSPENSION_STATE_ = 1 OR SUSPENSION_STATE_ IS NULL)
  UNION SELECT 52.1, 'Jobs (due at prio: ' || PRIORITY_ || ')', COUNT(*) FROM ACT_RU_JOB
    WHERE (RETRIES_ > 0)
    AND (DUEDATE_ IS NULL OR DUEDATE_ < SYSDATE)
    AND (LOCK_OWNER_ IS NULL OR LOCK_EXP_TIME_ < SYSDATE)
    AND (SUSPENSION_STATE_ = 1 OR SUSPENSION_STATE_ IS NULL)
    GROUP BY PRIORITY_
  UNION SELECT 53, 'Jobs (waiting for timer)', COUNT(*) FROM ACT_RU_JOB
    WHERE (RETRIES_ > 0)
    AND (DUEDATE_ IS NOT NULL AND DUEDATE_ >= SYSDATE)
    AND (LOCK_OWNER_ IS NULL OR LOCK_EXP_TIME_ < SYSDATE)
    AND (SUSPENSION_STATE_ = 1 OR SUSPENSION_STATE_ IS NULL)
  UNION SELECT 54, 'Jobs (suspended)', COUNT(*) FROM ACT_RU_JOB WHERE SUSPENSION_STATE_ = 2
  UNION SELECT 55, 'Jobs (failed)', COUNT(*) FROM ACT_RU_JOB WHERE RETRIES_ = 0
  UNION SELECT 56, 'Jobs (timeout)', COUNT(*) FROM ACT_RU_JOB
    WHERE (LOCK_OWNER_ IS NOT NULL AND LOCK_EXP_TIME_ < SYSDATE)
  UNION SELECT 59, 'Jobs (type: ' || TO_CHAR(TYPE_) || ')', COUNT(*) FROM ACT_RU_JOB GROUP BY TYPE_
  UNION SELECT 60, 'Process Variables', COUNT(*) FROM ACT_RU_VARIABLE
  )
ORDER BY 1,2;