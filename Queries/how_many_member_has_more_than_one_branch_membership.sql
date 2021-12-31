SELECT SUM(members_branches.member_id) AS Total_members_with_more_than_1_branch_membership
FROM members_branches
WHERE members_branches.member_id >= 2;