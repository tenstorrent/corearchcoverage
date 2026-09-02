# SPDX-FileCopyrightText: © 2026 Tenstorrent AI ULC
# SPDX-License-Identifier: Apache-2.0

"""Orchestrate Whisper, cov_gen, and cp_pkg generation for corearchcoverage."""

import argparse
import os
import subprocess
import sys
from typing import List, Optional

_MAKE_JOBS = "10"

def _c_compiler_path_for_vcs(cxx_path: str) -> str:
    """Return a C compiler path for VCS ``-cc``.

    VCS generated makefiles set ``VCS_CC=gcc`` and compile DPI stubs with
    ``$(CC)``; ``-cpp`` / ``-ld`` do not replace that ``CC``. Passing ``-cc``
    points the stub compile (which still receives ``-CFLAGS`` such as
    ``-std=c++20``) at a sufficiently new *gcc* from the same toolchain as
    ``cxx_path`` (e.g. toolset ``g++`` -> sibling ``gcc``).
    """
    cxx_abs = os.path.abspath(os.path.expanduser(cxx_path))
    d, base = os.path.dirname(cxx_abs), os.path.basename(cxx_abs)
    if base in ("g++", "c++"):
        cc = os.path.join(d, "gcc")
    elif base == "clang++":
        cc = os.path.join(d, "clang")
    elif base.endswith("g++") and len(base) > 3:
        cc = os.path.join(d, base[:-3] + "gcc")
    else:
        cc = cxx_abs
    if cc != cxx_abs and not os.path.isfile(cc):
        raise RuntimeError(
            f"Derived C compiler for VCS -cc not found: {cc} (from CXX {cxx_abs}). "
            "Install the matching gcc next to g++, or extend _c_compiler_path_for_vcs."
        )
    return cc


def _boost_install_dir(boost_lib_path: str) -> str:
    p = os.path.abspath(os.path.expanduser(boost_lib_path))
    base = os.path.basename(p.rstrip(os.sep))
    if base == "lib":
        return os.path.dirname(p)
    lib_child = os.path.join(p, "lib")
    inc_child = os.path.join(p, "include")
    if os.path.isdir(lib_child) or os.path.isdir(inc_child):
        return p
    return os.path.dirname(p)

def clean_whisper() -> None:
    project_root = check_project_root()
    whisper_dir = os.path.join(project_root, "whisper")
    subprocess.run(["make", "-C", whisper_dir, "clean"], check=True)

def clean_cov_gen() -> None:
    project_root = check_project_root()
    subprocess.run(["make", "-C", project_root, "clean_all"], check=True)

def clean_cp_pkg() -> None:
    project_root = check_project_root()
    subprocess.run(["rm", "-rf", os.path.join(project_root, "packages")], check=True)

def clean_autogen_samples() -> None:
    project_root = check_project_root()
    subprocess.run(["rm", "-rf", os.path.join(project_root, "autogen_samples")], check=True)

def clean_all() -> None:
    clean_whisper()
    clean_cov_gen()
    clean_cp_pkg()
    clean_autogen_samples()

def check_project_root() -> None:
    project_root = os.environ.get("PROJECT_ROOT")
    if not project_root:
        raise RuntimeError("PROJECT_ROOT environment variable is not set")
    return project_root

def build_whisper(boost_lib_path: str, cxx_path: str) -> None:
    print(f"Building Whisper")
    project_root = check_project_root()
    whisper_dir = os.path.join(project_root, "whisper")

    if not os.path.isdir(whisper_dir):
        raise RuntimeError(f"Whisper directory does not exist: {whisper_dir}")

    boost_dir = _boost_install_dir(boost_lib_path)
    
    cxx = os.path.abspath(cxx_path)
    
    cmd = [
        "make",
        "-C",
        whisper_dir,
        "-j",
        _MAKE_JOBS,
        f"CXX={cxx}",
        f"BOOST_DIR={boost_dir}",
        "SOFT_FLOAT=1",
        "MEM_CALLBACKS=1",
        "TRACE_READER=1",
    ]
    
    try:
        subprocess.run(cmd, check=True)
        print(f"✔ WHISPER BUILD SUCCESSFUL!")
    except subprocess.CalledProcessError as e:
        raise RuntimeError(
            f"✘ WHISPER BUILD FAILED: make exited with status {e.returncode}"
        ) from e

def build_cov_gen(boost_lib_path: str, cxx_path: str) -> None:
    project_root = check_project_root()

    boost_dir = _boost_install_dir(boost_lib_path)

    cxx = os.path.abspath(cxx_path)
    
    cmd = [
        "make",
        "-j",
        _MAKE_JOBS,
        f"CXX={cxx}",
        f"BOOST_DIR={boost_dir}",
    ]
    
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        raise RuntimeError(
            f"✘ COV_GEN BUILD FAILED: make exited with status {e.returncode}"
        ) from e

def run_cov_gen(whisper_config: str) -> None:
    project_root = check_project_root()
    cov_gen_dir = os.path.join(project_root, "build")
    subprocess.run([os.path.join(cov_gen_dir, "cov_gen"),"--whisper_config", whisper_config], check=True)

def generate_autogen_samples(cp_pkg_path: str) -> None:
    project_root = check_project_root()
    autogen_samples_dir = os.path.join(project_root, "autogen_samples")
    subprocess.run(["python3", os.path.join(project_root, "scripts", "gen_cov_sample.py"), "--cp_pkg", cp_pkg_path], check=True)

def run_simulation(boost_lib_path: str, cxx_path: str, whisper_config: str, test: str) -> None:
    log_file = "compile.log"
    project_root = check_project_root()
    boost_dir = _boost_install_dir(boost_lib_path)
    cxx = os.path.abspath(cxx_path)
    cc = _c_compiler_path_for_vcs(cxx_path)
    cflags_str = (
        f"-std=c++20 -O2 -Wall "
        f"-I{project_root}/cov_gen/common "
        f"-I{project_root}/whisper "
        f"-I{project_root}/magic_enum/include/magic_enum "
        f"-I{boost_dir}/include "
        f"-I{project_root}/whisper/third_party"
    )
    ldflags_str = (
        f"-L{boost_dir}/lib "
        # VCS sets its own RPATH on simv, so the Boost lib dir must be baked in
        # explicitly or the loader cannot find libboost_program_options.so.
        f"-Wl,-rpath={boost_dir}/lib "
        f"-L{project_root}/whisper/build-Linux "
        f"-L{project_root}/whisper/virtual_memory "
        f"-L{project_root}/whisper/pci"
    )
    vcs_command = [
        "vcs",
        "-full64",
        "-f", os.path.join(project_root, "sim.f"),
        "+define+STANDALONE_COV=1",

        # Pass the single CFLAGS string
        "-CFLAGS", cflags_str,

        # Pass the single LDFLAGS string
        "-LDFLAGS", ldflags_str,
        
        # Libraries
        "-lrvcore",
        "-lboost_program_options",
        "-lvirtual_memory",
        "-lpci",
        "-lz",
        "-lm",
        "-lpthread",
        "-ldl",
        "-lrt",
        "-lutil",
        
        # Static libraries
        f"{project_root}/whisper/third_party/softfloat/build/RISCV-GCC/softfloat.a",

        # C compiler for generated make (DPI stubs use $(CC)); -cpp/-ld alone
        # do not replace VCS_CC.
        "-cc", cc,
        "-cpp", cxx,
        "-ld", cxx,

        # Output executable
        "-o", "simv"
    ]
    # --- Execute the Command (same as before) ---
    try:
        print(f"Executing command: {' '.join(vcs_command)}")
        with open(log_file, "w") as f:
            result = subprocess.run(
                vcs_command,
                stdout=f,
                stderr=subprocess.STDOUT,
                check=True,
                universal_newlines=True
            )
        print(f"✔ VCS COMPILATION SUCCESSFUL!")
        return run_simulation_with_whisper(whisper_config=whisper_config, test=test)

    except FileNotFoundError:
        print(f"Error: The 'vcs' command was not found.")
        return False
    except subprocess.CalledProcessError as e:
        print(f"✘ VCS compilation failed with exit code {e.returncode}.")
        print(f"  Check the log file '{log_file}' for details.")
        return False
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        return False

def run_simulation_with_whisper(whisper_config: str, test: str) -> None:
    print(f"RUNNING SIMULATION WITH WHISPER: {whisper_config} AND TEST: {test}")
    project_root = check_project_root()
    simv = os.path.join(project_root, "simv")
    cmd = [
        simv,
        f"+whisper_json_path={whisper_config}",
        f"+load={test}",
    ]
    print(f"Executing command: {' '.join(cmd)}")
    print("-" * 60)
    if not os.path.isfile(simv):
        raise RuntimeError(f"Simulation executable not found: {simv}")
    try:
        subprocess.run(cmd, check=True, universal_newlines=True)
        print(f"✔ SIMULATION WITH WHISPER SUCCESSFUL!")
        return True
    except subprocess.CalledProcessError as e:
        print(f"✘ SIMULATION WITH WHISPER FAILED WITH EXIT CODE {e.returncode}.")
        return False
    except Exception as e:
        print(f"✘ UNEXPECTED ERROR OCCURRED: {e}")
        return False

def parse_args(argv):
    parser = argparse.ArgumentParser(
        description="Build and run coverage flow for corearchcoverage.",
    )
    parser.add_argument(
        "--boost_lib_path",
        required=False,
        help="Boost install path",
    )
    parser.add_argument(
        "--cxx_path",
        required=False,
        help="Path to the C++ compiler",
    )
    parser.add_argument(
        "--whisper_config",
        required=False,
        help="Path to the Whisper configuration file",
    )
    parser.add_argument(
        "--cp_pkg_path",
        required=False,
        help="Path to the cp_pkg.sv file",
    )
    parser.add_argument(
        "--test",
        required=False,
        help="Path to the test binary",
    )
    parser.add_argument(
        "--clean_all",
        action="store_true",
        default=False,
        help="Clean all build artifacts (default: false).",
    )
    parser.add_argument(
        "--build_whisper_only",
        action="store_true",
        default=False,
        help="Only build Whisper (default: false).",
    )
    parser.add_argument(
        "--build_cov_gen_only",
        action="store_true",
        default=False,
        help="Build cov_gen only (default: false).",
    )
    parser.add_argument(
        "--run_cov_gen_only",
        action="store_true",
        default=False,
        help="Only regenerate cp_pkg (default: false).",
    )
    parser.add_argument(
        "--run_gen_cov_sample_only",
        action="store_true",
        default=False,
        help="Only generate autogen samples (default: false).",
    )
    parser.add_argument(
        "--run_sim_only",
        action="store_true",
        default=False,
        help="Only run coverage simulation with whisper (default: false). Currently, the script only supports vcs simulator.",
    )
    parser.add_argument(
        "--clean_and_build_all",
        action="store_true",
        default=False,
        help="Build all components (default: false).",
    )
    return parser.parse_args(argv)

def main(argv):
    args = parse_args(argv)

    try:
        if args.clean_all:
            clean_all()

        if args.build_whisper_only:
            if not args.boost_lib_path or not args.cxx_path:
                raise RuntimeError("Boost library path and C++ compiler path are required for building Whisper")
            build_whisper(args.boost_lib_path, args.cxx_path)

        if args.build_cov_gen_only:
            if not args.boost_lib_path or not args.cxx_path:
                raise RuntimeError("Boost library path and C++ compiler path are required for building Cov_gen")
            build_cov_gen(args.boost_lib_path, args.cxx_path)

        if args.run_cov_gen_only:
            if not args.whisper_config:
                raise RuntimeError("Whisper configuration file is required for running Cov_gen")
            run_cov_gen(args.whisper_config)

        if args.run_gen_cov_sample_only:
            if not args.cp_pkg_path:
                raise RuntimeError("Path to the cp_pkg.sv file is required for generating autogen samples")
            generate_autogen_samples(args.cp_pkg_path)

        if args.run_sim_only:
            if not args.boost_lib_path or not args.cxx_path or not args.whisper_config or not args.test:
                raise RuntimeError("Following arguments are required for running simulation: boost_lib_path, cxx_path, whisper_config, test")
            run_simulation(boost_lib_path=args.boost_lib_path, cxx_path=args.cxx_path, whisper_config=args.whisper_config, test=args.test)

        if args.clean_and_build_all:
            project_root = check_project_root()
            if not args.boost_lib_path or not args.cxx_path or not args.whisper_config or not args.test:
                raise RuntimeError("Following arguments are required for building all components: boost_lib_path, cxx_path, whisper_config, test")
            clean_all()
            build_whisper(args.boost_lib_path, args.cxx_path)
            build_cov_gen(args.boost_lib_path, args.cxx_path)
            run_cov_gen(args.whisper_config)
            cp_pkg_path = os.path.join(project_root, "packages", "cp_pkg.sv")
            generate_autogen_samples(cp_pkg_path)
            run_simulation(args.boost_lib_path, args.cxx_path, args.whisper_config, args.test)

    except RuntimeError as e:
        print(e, file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
