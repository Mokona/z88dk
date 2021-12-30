//-----------------------------------------------------------------------------
// z80asm
// Copyright (C) Paulo Custodio, 2011-2021
// License: The Artistic License 2.0, http://www.perlfoundation.org/artistic_license_2_0
//-----------------------------------------------------------------------------

#include "if.h"
#include "lex.h"
#include <cstdint>
#include <vector>
using namespace std;

class FloatExpr {
public:
	FloatExpr(Lexer& lexer);

	bool parse();
	bool eval_error() const { return m_eval_error; }
	double value() const { return m_value; }

private:
	Lexer& m_lexer;
	double m_value{ 0.0 };
	bool   m_parse_error{ false };	// expression cound not be parsed
	bool   m_eval_error{ false };	// expression cound not be evaluated

	double parse_expr();
	double parse_addition();
	double parse_multiplication();
	double parse_power();
	double parse_unary();
	double parse_primary();
	double parse_func(double(*f)(double));
	double parse_func2(double(*f)(double, double));
};

class FloatRepr {
public:
	enum class Format {
#define X(type, fp_size, fp_exponent_bias, fp_mantissa_bytes, fp_fudge_offset)	\
		type,
#include "float.def"
	};

	FloatRepr(double value = 0.0);

	double value() const { return m_value; };
	void set_value(double value) { m_value = value; }

	static Format format() { return c_format; }
	static void set_format(Format format);
	static bool set_format(const string& text);
	static string format_define();

	vector<uint8_t> convert();
	string convert_int_list();

private:
	// from sccz80
	static inline const int MAX_MANTISSA_SIZE = 7;

	struct fp_decomposed {
		uint8_t   exponent{ 0 };
		uint8_t   sign{ 0 };
		uint8_t   mantissa[MAX_MANTISSA_SIZE + 1]{ 0 };
	};

	// data
	double	m_value{ 0.0 };
	uint8_t m_fa[MAX_MANTISSA_SIZE + 1]{ 0 };

	static inline Format c_format{ Format::genmath };		// TODO: define appropriate default
	static inline int c_fp_size{ 6 };
	static inline int c_fp_exponent_bias{ 128 };
	static inline int c_fp_mantissa_bytes{ 5 };
	static inline int c_fp_fudge_offset{ 0 };

	// converters for each type
#define X(type, fp_size, fp_exponent_bias, fp_mantissa_bytes, fp_fudge_offset)	\
	void convert__##type();
#include "float.def"

	// from sccz80
	void pack32bit_float(uint32_t val);
	void decompose_float(double raw, struct fp_decomposed* fs);
};

bool set_float_format(const char* format);
const char* get_float_format_define(void);
