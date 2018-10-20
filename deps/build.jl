using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    # LibraryProduct(prefix, ["libLLVM"], :libLLVM),
    # LibraryProduct(prefix, ["libLTO"], :libLTO),
    LibraryProduct(prefix, ["libclang"], :libclang),
    # FileProduct(prefix, "tools/llvm-config", :llvm_config),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/ihnorton/Clang.jl/releases/download/Julia1.0-compatible"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:i686, libc=:glibc) => ("$bin_prefix/LLVM.v6.0.0.i686-linux-gnu.tar.gz", "5eb9c07f75a509209dfac39d82afacd680f37a740225a00ceb308634e615f5a2"),
    Windows(:i686) => ("$bin_prefix/LLVM.v6.0.0.i686-w64-mingw32.tar.gz", "6e2f786ece1fc434ea09f2c67cc71a5f8254ac724430ba018238c1e94b4f053b"),
    MacOS(:x86_64) => ("$bin_prefix/LLVM.v6.0.0.x86_64-apple-darwin14.tar.gz", "e5a4c727fbb12b7561b735d598891ac291232c6f236248e7288786b695e87359"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/LLVM.v6.0.0.x86_64-linux-gnu.tar.gz", "9a0356167fb31ea1d9d0c46296e13cbd14f748cb0830ef6f9b1772fb13287d63"),
    Windows(:x86_64) => ("$bin_prefix/LLVM.v6.0.0.x86_64-w64-mingw32.tar.gz", "79d07b020fa4da023ededa8f9249141becaaa48eb33c52c13c9b1134aadf509e"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
