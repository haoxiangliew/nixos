{ stdenv, lib, unstick, fetchurl, supportedDevices ? [
  "Arria II"
  "Cyclone V"
  "Cyclone IV"
  "Cyclone 10 LP"
  "MAX II/V"
  "MAX 10 FPGA"
] }:

let
  deviceIds = {
    "Arria II" = "arria_lite";
    "Cyclone V" = "cyclonev";
    "Cyclone IV" = "cyclone";
    "Cyclone 10 LP" = "cyclone10lp";
    "MAX II/V" = "max";
    "MAX 10 FPGA" = "max10";
  };

  supportedDeviceIds = assert lib.assertMsg
    (lib.all (name: lib.hasAttr name deviceIds) supportedDevices)
    "Supported devices are: ${
      lib.concatStringsSep ", " (lib.attrNames deviceIds)
    }";
    lib.listToAttrs (map (name: {
      inherit name;
      value = deviceIds.${name};
    }) supportedDevices);

  unsupportedDeviceIds =
    lib.filterAttrs (name: value: !(lib.hasAttr name supportedDeviceIds))
    deviceIds;

  # 20.1
  # componentHashes = {
  #   "arria_lite" = "140jqnb97vrxx6398cpgpw35zrrx3z5kv1x5gr9is1xdbnf4fqhy";
  #   "cyclone" = "116kf69ryqcmlc2k8ra0v32jy7nrk7w4s5z3yll7h3c3r68xcsfr";
  #   "cyclone10lp" = "07wpgx9bap6rlr5bcmr9lpsxi3cy4yar4n3pxfghazclzqfi2cyl";
  #   "cyclonev" = "11baa9zpmmfkmyv33w1r57ipf490gnd3dpi2daripf38wld8lgak";
  #   "max" = "1zy2d42dqmn97fwmv4x6pmihh4m23jypv3nd830m1mj7jkjx9kcq";
  #   "max10" = "1hvi9cpcjgbih3l6nh8x1vsp0lky5ax85jb2yqmzla80n7dl9ahs";
  # };

  # 18.1
  componentHashes = {
    "arria_lite" =
      "032621c1914586a484aefeadca04b7e52030493898ffae9aa9d09b24b6a906b6";
    "cyclone" =
      "cb19bc70de45af52490f53b15931861949ce460cbcdf92aec4fd01192c957efd";
    "cyclone10lp" =
      "52c4cc3bc2d2becd5f93bded3052cdd8586c4e6f7088b0c8332a14bf20077e08";
    "cyclonev" =
      "03f89491eeb1a9dafb8b9d244db34f4fe25da1a5fd38d07c499733444c456329";
    "max" = "a833a1ff1875b836d3ced61e2dad84de569d9798ba633b79e85108ee3138ba35";
    "max10" =
      "78f2103e815d9a87e121fc9809aef76dc7b39a0d415ac68fba56dcf6b61c7d4a";
  };

  # version = "20.1.1.720";
  version = "18.1.0.625";

  # 20.1
  # download = { name, sha256 }:
  #   fetchurl {
  #     inherit name sha256;
  #     # e.g. "20.1.1.720" -> "20.1std.1/720"
  #     url = "https://download.altera.com/akdlm/software/acdsinst/${
  #         lib.versions.majorMinor version
  #       }std.${lib.versions.patch version}/${
  #         lib.elemAt (lib.splitVersion version) 3
  #       }/ib_installers/${name}";
  #   };

  # 18.1
  download = { name, sha256 }:
    fetchurl {
      inherit name sha256;
      # e.g. "18.1.0.625" -> "18.1std/625"
      url = "https://download.altera.com/akdlm/software/acdsinst/${
          lib.versions.majorMinor version
        }std/${lib.elemAt (lib.splitVersion version) 3}/ib_installers/${name}";
    };

in stdenv.mkDerivation rec {
  inherit version;
  pname = "quartus-prime-lite-unwrapped";

  # 20.1
  # src = map download ([
  #   {
  #     name = "QuartusLiteSetup-${version}-linux.run";
  #     sha256 = "0mjp1rg312dipr7q95pb4nf4b8fwvxgflnd1vafi3g9cshbb1c3k";
  #   }
  #   {
  #     name = "ModelSimSetup-${version}-linux.run";
  #     sha256 = "1cqgv8x6vqga8s4v19yhmgrr886rb6p7sbx80528df5n4rpr2k4i";
  #   }
  # ] ++ (map (id: {
  #   name = "${id}-${version}.qdz";
  #   sha256 = lib.getAttr id componentHashes;
  # }) (lib.attrValues supportedDeviceIds)));

  # 18.1
  src = map download ([
    {
      name = "QuartusLiteSetup-${version}-linux.run";
      sha256 =
        "06d975f65f86290719407f92d6364487a713650388f583a8e2f251694bc45513";
    }
    {
      name = "ModelSimSetup-${version}-linux.run";
      sha256 =
        "02e2a5ada4cdad78a1988508a98f8851c1a47ca82297ec4dc67b19b9414f52c1";
    }
  ] ++ (map (id: {
    name = "${id}-${version}.qdz";
    sha256 = lib.getAttr id componentHashes;
  }) (lib.attrValues supportedDeviceIds)));

  nativeBuildInputs = [ unstick ];

  buildCommand = let
    installers = lib.sublist 0 2 src;
    components = lib.sublist 2 ((lib.length src) - 2) src;
    copyInstaller = installer: ''
      # `$(cat $NIX_CC/nix-support/dynamic-linker) $src[0]` often segfaults, so cp + patchelf
      cp ${installer} $TEMP/${installer.name}
      chmod u+w,+x $TEMP/${installer.name}
      patchelf --interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $TEMP/${installer.name}
    '';
    copyComponent = component: "cp ${component} $TEMP/${component.name}";
    # leaves enabled: quartus, modelsim_ase, devinfo
    disabledComponents = [
      "quartus_help"
      "quartus_update"
      # not modelsim_ase
      "modelsim_ae"
    ] ++ (lib.attrValues unsupportedDeviceIds);
  in ''
    ${lib.concatMapStringsSep "\n" copyInstaller installers}
    ${lib.concatMapStringsSep "\n" copyComponent components}

    unstick $TEMP/${(builtins.head installers).name} \
      --disable-components ${lib.concatStringsSep "," disabledComponents} \
      --mode unattended --installdir $out --accept_eula 1

    # [WARNING]: Quartus 18.1 requirement
    patch --force --strip 0 --directory $out < ${./vsim.patch}

    rm -r $out/uninstall $out/logs
  '';

  meta = with lib; {
    homepage = "https://fpgasoftware.intel.com";
    description = "FPGA design and simulation software";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ haoxiangliew ];
  };
}
