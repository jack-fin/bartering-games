-- name: GetUserByID :one
SELECT id, created_at
FROM users
WHERE id = @id;
