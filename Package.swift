// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "MetaHDF5",
  platforms: [
    .macOS(.v14),
    .visionOS(.v1),
    .iOS(.v17),
    .tvOS(.v17),
    .watchOS(.v10),
  ],
  products: [
    .library(
      name: "HDF5",
      type: .dynamic,
      targets: ["HDF5"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/the-swift-collective/zlib", from: "1.3.1"),
  ],
  targets: [
    .target(
      name: "HDF5",
      dependencies: [
        .product(name: "ZLib", package: "zlib"),
      ],
      publicHeadersPath: "include",
      cSettings: [
        .define("H5_USE_18_API", to: "1"),
        .define("H5_BUILT_AS_DYNAMIC_LIB", to: "1"),
        .define("H5_HAVE_C99_FUNC", to: "1", .when(platforms: Arch.OS.apple.platform)),
        .define("H5_HAVE_FUNCTION", to: "1", .when(platforms: Arch.OS.linux.platform)),
        .define("H5_TIME_WITH_SYS_TIME", to: "1", .when(platforms: Arch.OS.linux.platform)),
        .define("hdf5_shared_EXPORTS", to: "1"),
      ],
      cxxSettings: [
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
      ]
    ),
  ],
  cLanguageStandard: .gnu17,
  cxxLanguageStandard: .cxx17
)

enum Arch
{
  enum OS
  {
    case apple
    case linux
    case windows
    case web
    case nix
    case applewindows
    case applewindowsdroid
    case nixnodroid
    case nodroid
    case nowasm

    var platform: [Platform]
    {
      switch self
      {
        case .apple: [.macOS, .iOS, .visionOS, .tvOS, .watchOS]
        case .linux: [.linux, .android, .openbsd]
        case .windows: [.windows]
        case .web: [.wasi]
        case .nix: [.macOS, .iOS, .visionOS, .tvOS, .watchOS, .linux, .android, .openbsd]
        case .applewindows: [.macOS, .iOS, .visionOS, .tvOS, .watchOS, .windows]
        case .applewindowsdroid: [.macOS, .iOS, .visionOS, .tvOS, .watchOS, .windows, .android]
        case .nixnodroid: [.macOS, .iOS, .visionOS, .tvOS, .watchOS, .linux, .openbsd]
        case .nodroid: [.macOS, .iOS, .visionOS, .tvOS, .watchOS, .linux, .openbsd, .windows]
        case .nowasm: [.macOS, .iOS, .visionOS, .tvOS, .watchOS, .linux, .android, .openbsd, .windows]
      }
    }
  }

  enum CPU: String
  {
    case arm
    case arm64
    case aarch64
    case x86_64
    case i386
    case powerpc
    case powerpc64
    case powerpc64le
    case s390x
    case wasm32
    case arm64_32

    var family: [CPU]
    {
      switch self
      {
        case .arm, .arm64, .aarch64, .arm64_32: [.arm, .arm64, .aarch64, .arm64_32]
        case .x86_64, .i386: [.x86_64, .i386]
        case .powerpc, .powerpc64, .powerpc64le: [.powerpc, .powerpc64, .powerpc64le]
        case .s390x: [.s390x]
        case .wasm32: [.wasm32]
      }
    }
  }

  #if os(macOS) || os(visionOS) || os(iOS) || os(tvOS) || os(watchOS)
    static let host = "apple"
    #if os(macOS)
      static let device = "macosx"
    #elseif os(visionOS)
      static let device = "xros"
    #elseif os(iOS)
      static let device = "ios"
    #elseif os(tvOS)
      static let device = "tvos"
    #elseif os(watchOS)
      static let device = "watchos"
    #endif
  #elseif os(Linux) || os(Android) || os(OpenBSD) || os(FreeBSD)
    static let host = "unknown-linux"
    #if os(Android)
      static let device = "android24"
    #else
      static let device = "gnu"
    #endif
  #elseif os(Windows)
    static let host = "unknown-windows"
    static let device = "msvc"
  #elseif os(Cygwin)
    static let host = "cygwin"
    static let device = "windows"
  #elseif os(WASI)
    static let host = "wasi"
    static let device = "wasi"
  #endif

  #if arch(arm64)
    #if os(Linux) || os(Android) || os(OpenBSD) || os(FreeBSD)
      static let cpuArch: CPU = .aarch64
    #else
      static let cpuArch: CPU = .arm64
    #endif
  #elseif arch(x86_64)
    static let cpuArch: CPU = .x86_64
  #elseif arch(i386)
    static let cpuArch: CPU = .i386
  #elseif arch(arm)
    static let cpuArch: CPU = .arm
  #elseif arch(powerpc64)
    static let cpuArch: CPU = .powerpc64
  #elseif arch(powerpc64le)
    static let cpuArch: CPU = .powerpc64le
  #elseif arch(powerpc)
    static let cpuArch: CPU = .powerpc
  #elseif arch(s390x)
    static let cpuArch: CPU = .s390x
  #elseif arch(wasm32)
    static let cpuArch: CPU = .wasm32
  #elseif arch(arm64_32)
    static let cpuArch: CPU = .arm64_32
  #endif
}
