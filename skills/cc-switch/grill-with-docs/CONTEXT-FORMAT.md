# CONTEXT.md 格式

## 结构

```md
# {上下文名称}

{一两句话描述这个上下文是什么以及为什么存在。}

## Language

**Order**:
{对该术语的简洁描述}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account

## Relationships

- An **Order** produces one or more **Invoices**
- An **Invoice** belongs to exactly one **Customer**

## Example dialogue

> **Dev:** "When a **Customer** places an **Order**, do we create the **Invoice** immediately?"
> **Domain expert:** "No — an **Invoice** is only generated once a **Fulfillment** is confirmed."

## Flagged ambiguities

- "account" was used to mean both **Customer** and **User** — resolved: these are distinct concepts.
```

## 规则

- **要有主张。** 当同一概念存在多个词汇时，选最好的那个，把其他的列为应避免使用的别名。
- **明确标记冲突。** 如果某个术语被含糊使用，在"Flagged ambiguities"中指出并给出明确的解决方案。
- **定义要简短。** 最多一句话。定义它**是什么**，而不是它**做什么**。
- **展示关系。** 使用加粗的术语名称，在明显的情况下标注基数关系。
- **只收录本项目上下文特有的术语。** 通用编程概念（超时、错误类型、工具模式）不在此列，即使项目大量使用它们。在添加术语前自问：这是本上下文特有的概念，还是通用编程概念？只有前者才属于这里。
- **当自然的分组出现时，用子标题组织术语。** 如果所有术语属于同一个内聚的领域，平铺列表即可。
- **写一段示例对话。** 开发者和领域专家之间的对话，展示术语如何自然交互，并明确相关概念之间的界限。

## 单上下文 vs 多上下文仓库

**单上下文（大多数仓库）：** 仓库根目录一个 `CONTEXT.md`。

**多上下文：** 仓库根目录的 `CONTEXT-MAP.md` 列出所有上下文、它们的位置以及相互关系：

```md
# Context Map

## Contexts

- [Ordering](./src/ordering/CONTEXT.md) — receives and tracks customer orders
- [Billing](./src/billing/CONTEXT.md) — generates invoices and processes payments
- [Fulfillment](./src/fulfillment/CONTEXT.md) — manages warehouse picking and shipping

## Relationships

- **Ordering → Fulfillment**: Ordering emits `OrderPlaced` events; Fulfillment consumes them to start picking
- **Fulfillment → Billing**: Fulfillment emits `ShipmentDispatched` events; Billing consumes them to generate invoices
- **Ordering ↔ Billing**: Shared types for `CustomerId` and `Money`
```

该 skill 推断适用哪种结构：

- 如果 `CONTEXT-MAP.md` 存在，读取它来发现上下文
- 如果只有根目录的 `CONTEXT.md`，则是单上下文
- 如果都不存在，在第一个术语确定时按需创建根目录的 `CONTEXT.md`

当存在多个上下文时，推断当前话题属于哪个。如果不确定，就问。
