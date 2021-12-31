SELECT staffs.first_name, staffs.last_name, branches.name AS Branch
FROM staffs
INNER JOIN staff_working
ON staffs.id = staff_working.staff_id
INNER JOIN branches
ON staff_working.branch_id = branches.id
WHERE staffs.designation = 'manager'
GROUP BY staffs.first_name, staffs.last_name
ORDER BY staffs.first_name, staffs.last_name;