# Postgres

自增 Id 数据插入权限

```sql
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO <user_name>;
```

修改用户密码

```sql
alter user postgres with password 'admin123';
```
