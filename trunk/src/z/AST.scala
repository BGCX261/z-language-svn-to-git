package z
import java.util.Vector

case class Program(stats: Vector[Statement]) {
	def this() {
		this(new Vector[Statement]())
	}

	def this(stats: Statement*) {
		this()
		var i = 0

		for (stat <- stats)
			append(stat)
	}

    def append(stat: Statement) {
        stats.add(stat)
    }
}

abstract class Statement
case class NullStatement extends Statement
case class ExpressionStatement(expression: Expression) extends Statement
case class DeclarationStatement(
	typeExpr: Expression,
	name: IdentifierExpression,
	initialValue: Option[Statement]) extends Statement {

	def this(
		typeExpr: Expression,
		name: IdentifierExpression,
		initialValue: Statement) {
		this(typeExpr, name, Some(initialValue))
	}

	def this(typeExpr: Expression, name: IdentifierExpression) {
		this(typeExpr, name, None)
	}
}

abstract class Expression
case class IntegerExpression(value: Int) extends Expression
case class IdentifierExpression(value: String) extends Expression
case class BinaryOperatorExpression(
	operator: Operator,
	lhs: Expression,
	rhs: Expression) extends Expression

abstract class Operator
case class Add extends Operator
case class Minus extends Operator
case class Mul extends Operator

/*
abstract class Stat
case class AssignStat(variable: String, value: Expr) extends Stat
case class ExprStat(value: Expr) extends Stat

abstract class Expr
case class AddExpr(lhs: Expr, rhs: Expr) extends Expr
case class SubExpr(lhs: Expr, rhs: Expr) extends Expr
case class MultExpr(lhs: Expr, rhs: Expr) extends Expr
case class IdExpr(id: String) extends Expr
case class IntExpr(value: Int) extends Expr
*/
