# SecureADODB Fork
I started working on SecureADODB to
 - practice VBA OOP, extending both my understanding and practical skill
 - deeply learn the original SecureADODB project
 - to see if I can identify improvement opportunities and implement them.

So, this project is largely a learning exercise for me, but I also plan to use it in another project, which can benefit from an ADODB VBA library.  
 
 ## Class diagram and mapping to `ADODB`

The class diagram below shows the core `SecureADODB` classes (this fork, blue) and the mapping to the core `ADODB` classes (green).

![SecureADODB-ADODB](https://github.com/pchemguy/RDVBA-examples/blob/develop/UML%20Class%20Diagrams/SecureADODB%20-%20ADODB%20Class%20Mapping.svg)

`DbRecordset` class has been added in this fork, while `DbManager` class shown at the bottom is functionally similar to the `UnitOfWork` class from the base project.
`DbManager` implements typical workflow and is, thus, responsible for streamlining the interaction process with the database. Since `SecureADODB` library has been designed in such a way to ensure maximal decoupling of classes responsible for different functions, an additional class UoF/DbManager is useful to put it all together. It takes connection parameters or connection string and then instantiates other classes and taking care of injecting dependencies as necessary.

`DbConnection` and `DbRecordset` classes receive and handle events generated by the corresponding `ADODB` classes (which was part of the motivation for creating `DbRecordset` class). While the most important events from `ADODB.Connection` are probably those related to connection/execution/transaction and related error events, events generated by the `ADODB.Recordset` among other things facilitate asynchronous fetching, which is something I might explore in the future.

## Summary of the core differences from the base project

1.  A coupling loop between `DbConnection` and `DbCommand` has been removed (issue [`IDbConnection_CreateCommand` interface](https://github.com/pchemguy/RDVBA-examples/issues/14)).
2.  `AutoDbCommand` and `DefaultDbCommand` have been replace with `DbCommand`, and `DefaultDbCommandFactory` with `DbCommandFactory`.
    `DbCommand` always takes an existing `DbConnection` as a dependency, and is only responsible for `ExecuteNoQuery` functionality ([NoQuery flag](https://github.com/pchemguy/RDVBA-examples/commit/ffc12ffb361ecc5a2338a321d84e8a756b48e109) commit), while queries returning a Recordset or a scalar are executed via the DbRecordset class.
3.  DbManager takes a flag indicating whether transactions should be used. Additionally, an error handler has been added to the BeginTransaction method. If this handler traps an error, it sets a flag on DbConnection object disabling further transaction handling.
4.  Class design patterns.
    1) Factory-constructor pattern. Following the convention of the base project, `Create` method is used as the default concrete factory method on default class instances. Initialization, on the other hand is not performed by a set of public setters, but rather via a corresponding constructor ([Factory-Constructor pattern](https://github.com/pchemguy/RDVBA-examples/issues/11) issue).
    2) Abstract factory and `CreateInstance` convention. Further, when abstract factory pattern is used, factory's Create method generate factory instances, whereas CreateInstance method called on a factory instances generates instances of the target class ([CreateInstance convention](https://github.com/pchemguy/RDVBA-examples/issues/10) issue).
    3) Duplicate `Guard` clauses. In several cases, there were duplicating checks by the Guard clauses, for example, the first happening in the factory method and subsequent checks in individual setters. The only Guard left in the factory class is the one checking for non-default instance invocation, which might be still somewhat redundant as well, if all instances always created against non-default interfaces, which lack the factory method. The received parameters are passed onto the corresponding constructor as is, where all parameters are validated once and in one place.
5.	`DbRecordset` class takes certain parameters directly, such as whether a disconnected or online recordset or scalar value should be returned. Cursor type and location, if not explicitly provided, are set based on the requested return type. For the most part, however, a fully initialized `ADODB.Command` (via injected `DbCommand` class) is used to prepare the recordset for opening. 
6.	Added `Guard` class implementing functionality from the Errors module with some refactoring and additional functionality.
7.	Added `Logger` class, a Scripting.Dictionary backed logger.
8.	Added a block of tests placed in one module (`DbManagerITests`), which are executed against test `CSV` and `SQLite` databases, which test actual, as opposed to stub, `SecureADODB` classes and also serve as use patterns.
