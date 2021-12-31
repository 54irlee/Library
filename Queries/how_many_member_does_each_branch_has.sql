SELECT branches.name AS branch_name, COUNT(members.id) AS Total_members
FROM branches
INNER JOIN members_branches
ON branches.id = members_branches.branch_id
INNER JOIN members
ON members_branches.member_id = members.id
GROUP BY branches.name
ORDER BY branches.name;