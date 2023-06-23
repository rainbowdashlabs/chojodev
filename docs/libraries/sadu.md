# SADU

**Links:** [Source Code](https://github.com/RainbowDashLabs/sadu/), [Wiki](https://github.com/rainbowdashlabs/sadu/wiki)

**Used Frameworks:** [HikariCP](https://github.com/brettwooldridge/HikariCP)

SQL and damn Utilities or short SADU is a library intended to make it easier to work with databases.

It has a query builder, which greatly shortens the amount of code required to read and write data from and into databases.

```sql
    public CompletableFuture<Optional<Result>> getResultNew(int id) {
        return builder(Result.class)
                .query("SELECT result FROM results WHERE id = ?")
                .parameters(stmt -> stmt.setInt(id))
                .readRow(rs -> new Result(rs.getString("result")))
                .first();
    }
```

The library was designed with beginners in mind. 
It ensures try with resources and can also directly log and handle errors if requested.
The query builder itself can validate already at compiletime, which makes it nearly impossible to use it in a wrong way.

Additionally, it supports creating a DataSource using HikariCP and allows to construct jdbc urls with predefined and documented values for MariaDB, PostgreSQL and SqLite.

It also contains an SQL updater, which maintains the currently used db schema of the database.
This is done via an internal version table and a set of user created migration scripts.

