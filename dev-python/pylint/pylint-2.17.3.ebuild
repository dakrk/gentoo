# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{9..11} )
PYTHON_REQ_USE="threads(+)"

inherit distutils-r1

DESCRIPTION="Python code static checker"
HOMEPAGE="
	https://pypi.org/project/pylint/
	https://github.com/pylint-dev/pylint/
"
SRC_URI="
	https://github.com/pylint-dev/pylint/archive/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
IUSE="examples"

# Make sure to check https://github.com/pylint-dev/pylint/blob/main/pyproject.toml#L34 on bumps
# Adjust dep bounds!
RDEPEND="
	<dev-python/astroid-2.17[${PYTHON_USEDEP}]
	>=dev-python/astroid-2.15.4[${PYTHON_USEDEP}]
	>=dev-python/dill-0.3.6[${PYTHON_USEDEP}]
	>=dev-python/isort-4.2.5[${PYTHON_USEDEP}]
	<dev-python/isort-6[${PYTHON_USEDEP}]
	>=dev-python/mccabe-0.6[${PYTHON_USEDEP}]
	<dev-python/mccabe-0.8[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-2.2.0[${PYTHON_USEDEP}]
	>=dev-python/tomlkit-0.10.1[${PYTHON_USEDEP}]
	$(python_gen_cond_dep '
		dev-python/typing-extensions[${PYTHON_USEDEP}]
	' 3.9)
	$(python_gen_cond_dep '
		>=dev-python/tomli-1.1.0[${PYTHON_USEDEP}]
	' 3.9 3.10)
"
BDEPEND="
	test? (
		>=dev-python/GitPython-3[${PYTHON_USEDEP}]
		dev-python/pytest-timeout[${PYTHON_USEDEP}]
		dev-python/typing-extensions[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

python_test() {
	rm -rf pylint || die

	local EPYTEST_DESELECT=(
		# TODO
		'tests/test_functional.py::test_functional[forgotten_debug_statement_py37]'
		'tests/test_functional.py::test_functional[dataclass_with_field]'
		'tests/test_functional.py::test_functional[no_name_in_module]'
		'tests/test_functional.py::test_functional[shadowed_import]'
		tests/checkers/unittest_typecheck.py::TestTypeChecker::test_nomember_on_c_extension_error_msg
		tests/checkers/unittest_typecheck.py::TestTypeChecker::test_nomember_on_c_extension_info_msg
		tests/config/pylint_config/test_run_pylint_config.py::test_invocation_of_pylint_config

		# apparently fragile, needs unpickleable plugin
		tests/test_check_parallel.py::TestCheckParallelFramework::test_linter_with_unpickleable_plugins_is_pickleable
	)
	local EPYTEST_IGNORE=(
		# No need to run the benchmarks
		tests/benchmark/test_baseline_benchmarks.py
	)
	epytest
}

python_install_all() {
	if use examples ; then
		docompress -x "/usr/share/doc/${PF}/examples"
		docinto examples
		dodoc -r examples/.
	fi

	distutils-r1_python_install_all
}
