FROM ghcr.io/luislavena/hydrofoil-crystal:1.7.3

# install cross-compiler
RUN --mount=type=cache,sharing=private,target=/var/cache/apk \
    --mount=type=tmpfs,target=/tmp \
    set -eux -o pipefail; \
    # Zig
    { \
        cd /tmp; \
        mkdir -p /opt/zig; \
        export ZIG_VERSION=0.11.0-dev.2297+28d6dd75a; \
        case "$(arch)" in \
        x86_64) \
            export \
                ZIG_ARCH=x86_64 \
                ZIG_SHA256=e004593a886222361825bbfbd6037334eec23fc1613b14f2e2621f33080eaea3 \
            ; \
            ;; \
        aarch64) \
            export \
                ZIG_ARCH=aarch64 \
                ZIG_SHA256=288411b4e75187189a712190eefa1814aad3ce8b2dfa0cb362b5dfeca7d703bf \
            ; \
            ;; \
        esac; \
        wget -q -O zig.tar.xz https://ziglang.org/builds/zig-linux-${ZIG_ARCH}-${ZIG_VERSION}.tar.xz; \
        echo "${ZIG_SHA256} *zig.tar.xz" | sha256sum -c - >/dev/null 2>&1; \
        tar -C /opt/zig --strip-components=1 -xf zig.tar.xz; \
        rm zig.tar.xz; \
        # symlink
        ln -nfs /opt/zig/zig /usr/local/bin; \
    }; \
    # smoke check
    [ "$(command -v zig)" = '/usr/local/bin/zig' ]; \
    zig version; \
    zig cc --version

# extract cross-compiling libs
ADD sdks/*.tar.xz /opt/magic-haversack/

# wrappers
COPY wrappers/ /usr/local/bin/
