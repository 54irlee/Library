SELECT branches.name AS branch_name, ROUND(AVG(members_branches.member_id)) AS average_membership
FROM branches
INNER JOIN members_branches
ON branches.id = members_branches.branch_id
GROUP BY branches.name
ORDER BY AVG(members_branches.member_id);