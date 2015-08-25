package z
import org.antlr.runtime._
import z.grammar._
import java.util.Vector

object Main {
	def assertEquals(expected: Any, actual: Any) {
		if (expected != actual) {
			println("Expected: " + expected + ", actual " + actual)
			assert(false)
		}
	}

	def assertNotEquals(unexpected: Any, actual: Any) {
		if (unexpected == actual) {
			println("Unexpected: " + unexpected)
			assert(false)
		}
	}

	def parse(program: String): Program = {
		val input = new ANTLRStringStream(program)
		val lexer = new ZLexer(input)
		val tokens = new CommonTokenStream(lexer)
		val parser = new ZParser(tokens)
		parser.program()
	}

	def testEmptyProgram() {
		val program = parse("")
		assertEquals(new Program(), program)
	}

	def testNullStatements() {
		assertEquals(new Program(NullStatement()), parse(";"))
		assertEquals(new Program(NullStatement(), NullStatement()), parse(";;"))
	}

	def testExpressionFails() {
		// XXX should make the following fail and expect it - now just
		// prints out an error message
		assertEquals(
			new Program(ExpressionStatement(IntegerExpression(1))),
			parse("1"))
	}

	val max_int = 2147483647;
	val max_int_plus_1: BigDecimal = BigDecimal("2147483648");

	def testIntegerExpressionStatement() {
		assertEquals(
			new Program(ExpressionStatement(IntegerExpression(123))),
			parse("123;"))
		assertEquals(
			new Program(
				ExpressionStatement(IntegerExpression(0)),
				ExpressionStatement(IntegerExpression(1234567890))
			),
			parse("0;\n1234567890;\n"))
	}
	
	def testIntegerExpressionLimits() {
		assertEquals(
			new Program(ExpressionStatement(IntegerExpression(max_int))),
			parse("" + max_int + ";"))

		try {
			parse("" + (max_int_plus_1) + ";")
			assert(false);
		} catch {
			case e: java.lang.NumberFormatException => ()
		}
	}

	// Statements of form <id> ;
	def testIdentifierExpressionStatement() {
		assertEquals(new Program(ExpressionStatement(
				IdentifierExpression("abc_XYZ"))),
			parse("abc_XYZ;"))

		// test case-sensitivity
		assertNotEquals(new Program(ExpressionStatement(
				IdentifierExpression("abc_XYZ"))),
			parse("ABC_xyz;"))
	}

	// Statements of form <expr> <id> ;
	def testDeclarationStatement() {
		assertEquals(
			new Program(
				new DeclarationStatement(
					IdentifierExpression("foo"),
					IdentifierExpression("bar")),
				new DeclarationStatement(
					IntegerExpression(123),
					IdentifierExpression("zot_bot"))),
			parse("foo bar;\n123 zot_bot;\n"))
	}

	def testDeclarationStatementWithInitializer() {
		assertEquals(
			new Program(
				new DeclarationStatement(
					IdentifierExpression("int"),
					IdentifierExpression("x"),
					ExpressionStatement(IntegerExpression(1)))),
			parse("int x = 1;"))

		// multiple nested declaration statements
		assertEquals(
			new Program(
				new DeclarationStatement(
					IdentifierExpression("int"),
					IdentifierExpression("x"),
					new DeclarationStatement(
						IdentifierExpression("int"),
						IdentifierExpression("y"),
						ExpressionStatement((IntegerExpression(1)))))),
			parse("int x = int y = 1;"))
	}
	
	def testArithmeticExpressions() {
		assertEquals(
			new Program(ExpressionStatement(BinaryOperatorExpression(
				Add(),
				IntegerExpression(1),
				IntegerExpression(2)))),
			parse("1 + 2;"))
		assertEquals(
			new Program(ExpressionStatement(
				BinaryOperatorExpression(
					Minus(),
					BinaryOperatorExpression(
						Add(),
						BinaryOperatorExpression(
							Mul(),
							IdentifierExpression("x"),
							IdentifierExpression("y")),
						IdentifierExpression("z")),
					BinaryOperatorExpression(
						Mul(),
						IntegerExpression(4),
						IdentifierExpression("w"))))),
			parse("x * y + z - 4 * w;"))
	}

	def runTests() {
		// simple programs
		testEmptyProgram()
		testNullStatements()

		// simple statements
		testIntegerExpressionStatement()
		testIntegerExpressionLimits()
		testIdentifierExpressionStatement()
		testDeclarationStatement()
		testDeclarationStatementWithInitializer()

		// expressions
		testArithmeticExpressions()
	}

	def main(args: Array[String]) = {
		for (arg <- args) {
			if (arg == "-t" || arg == "--test")
				runTests()
			else
				println("Program \"" + arg + "\": " + parse(arg))
		}
	}
}

