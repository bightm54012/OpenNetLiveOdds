專案架構說明
1. Swift Concurrency 使用場景
Repository 層（OddsRepository）
使用 actor 來管理 oddsMap。
方法像 seed(), apply(), odds(for:) 都是 async，呼叫時需要 await，避免 race condition。

2. Combine 使用場景
ViewModel 層（MatchesViewModel）
負責把 Repository / API / Socket 的資料轉換成 UI 可以綁定的 Publisher。

3. 如何確保資料存取 Thread-safe?
資料來源集中在 OddsRepository (actor)
actor 保證 thread-safe，不需要鎖。

ViewModel 本身不直接存取 Dictionary
只透過 Repository 提供的方法拿資料。
確保單一責任：ViewModel 管理 UI 狀態，Repository 管理資料一致性。

4. UI 與 ViewModel 資料綁定方式
(UIKit + Combine)
