{ stdenv
, lib
, unstick
, requireFile
, supportedDevices ? [ "Arria II" "Cyclone V" "Cyclone IV" "Cyclone 10 LP" "MAX II/V" "MAX 10 FPGA" ]
}:

let
  deviceIds = {
    "Arria II" = "arria_lite";
    "Cyclone V" = "cyclonev";
    "Cyclone IV" = "cyclone";
    "Cyclone 10 LP" = "cyclone10lp";
    "MAX II/V" = "max";
    "MAX 10 FPGA" = "max10";
  };

  supportedDeviceIds =
    assert lib.assertMsg (lib.all (name: lib.hasAttr name deviceIds) supportedDevices)
      "Supported devices are: ${lib.concatStringsSep ", " (lib.attrNames deviceIds)}";
    lib.listToAttrs (map
      (name: {
        inherit name;
        value = deviceIds.${name};
      })
      supportedDevices);

  unsupportedDeviceIds = lib.filterAttrs
    (name: value:
      !(lib.hasAttr name supportedDeviceIds)
    )
    deviceIds;

  # 21.1
  # componentHashes = {
  #   "arria_lite" = "09aa585ef730da2738423b739f2902bd413eb73b8746355cc112ddd6a8a8b5d4";
  #   "cyclone" = "f514ddbaede7f49b8cb0745f3497588b7456431d23342a3becadf235e683baf6";
  #   "cyclone10lp" = "98be82d58b8255c0ad4b4be7f91dbafbe66a2c01646196d3355b6802e00bd88d";
  #   "cyclonev" = "a87ef75b9cd5e2e9c82213b16a34f68289e9aa96e2baa4d94e1086bf2e13158a";
  #   "max" = "7b3993e57b0716eb5fb13b0027d383d43d427ddae5635cbcba9f92c326b93afa";
  #   "max10" = "5ed25b0b448a8f52dc7fbd7436c8d16a49fde8b9c03212c0e67fe79b48dbe727";
  # };

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
    "arria_lite" = "032621c1914586a484aefeadca04b7e52030493898ffae9aa9d09b24b6a906b6";
    "cyclone" = "cb19bc70de45af52490f53b15931861949ce460cbcdf92aec4fd01192c957efd";
    "cyclone10lp" = "52c4cc3bc2d2becd5f93bded3052cdd8586c4e6f7088b0c8332a14bf20077e08";
    "cyclonev" = "03f89491eeb1a9dafb8b9d244db34f4fe25da1a5fd38d07c499733444c456329";
    "max" = "a833a1ff1875b836d3ced61e2dad84de569d9798ba633b79e85108ee3138ba35";
    "max10" = "78f2103e815d9a87e121fc9809aef76dc7b39a0d415ac68fba56dcf6b61c7d4a";
  };

  # version = "21.1.1.850";
  # version = "20.1.1.720";
  version = "18.1.0.625";
  homepage = "https://fpgasoftware.intel.com";

  require = { name, sha256 }: requireFile {
    inherit name sha256;
    url = "${homepage}/${lib.versions.majorMinor version}/?edition=lite&platform=linux";
  };

in
stdenv.mkDerivation rec {
  inherit version;
  pname = "quartus-prime-lite-unwrapped";

  # 21.1
  # src = map require ([{
  #   name = "QuartusLiteSetup-${version}-linux.run";
  #   sha256 = "ea550740a2fc2d4ef459e4534f59ccb06a9aaa39afa3d85695b1503c1325ff4a";
  # }
  #   {
  #     name = "QuestaSetup-${version}-linux.run";
  #     sha256 = "16e541cf238fc2672b7387abaf2f31976c6acc6af1c08a39398ab418b5aed4f1";
  #   }] ++ (map
  #   (id: {
  #     name = "${id}-${version}.qdz";
  #     sha256 = lib.getAttr id componentHashes;
  #   })
  #   (lib.attrValues supportedDeviceIds)));

  # 20.1
  # src = map require ([{
  #   name = "QuartusLiteSetup-${version}-linux.run";
  #   sha256 = "0mjp1rg312dipr7q95pb4nf4b8fwvxgflnd1vafi3g9cshbb1c3k";
  # }
  #   {
  #     name = "ModelSimSetup-${version}-linux.run";
  #     sha256 = "1cqgv8x6vqga8s4v19yhmgrr886rb6p7sbx80528df5n4rpr2k4i";
  #   }] ++ (map
  #   (id: {
  #     name = "${id}-${version}.qdz";
  #     sha256 = lib.getAttr id componentHashes;
  #   })
  #   (lib.attrValues supportedDeviceIds)));

  # 18.1
  src = map require ([{
    name = "QuartusLiteSetup-${version}-linux.run";
    sha256 = "06d975f65f86290719407f92d6364487a713650388f583a8e2f251694bc45513";
  }
    {
      name = "ModelSimSetup-${version}-linux.run";
      sha256 = "02e2a5ada4cdad78a1988508a98f8851c1a47ca82297ec4dc67b19b9414f52c1";
    }] ++ (map
    (id: {
      name = "${id}-${version}.qdz";
      sha256 = lib.getAttr id componentHashes;
    })
    (lib.attrValues supportedDeviceIds)));

  nativeBuildInputs = [ unstick ];

  buildCommand =
    let
      installers = lib.sublist 0 2 src;
      components = lib.sublist 2 ((lib.length src) - 2) src;
      copyInstaller = installer: ''
        # `$(cat $NIX_CC/nix-support/dynamic-linker) $src[0]` often segfaults, so cp + patchelf
        cp ${installer} $TEMP/${installer.name}
        chmod u+w,+x $TEMP/${installer.name}
        patchelf --interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $TEMP/${installer.name}
      '';
      copyComponent = component: "cp ${component} $TEMP/${component.name}";
      # leaves enabled: quartus, modelsim_ase / questa_fse, devinfo
      disabledComponents = [
        "quartus_help"
        "quartus_update"
        # not modelsim_ase
        "modelsim_ae"
      ] ++ (lib.attrValues unsupportedDeviceIds);
    in
    ''
      ${lib.concatMapStringsSep "\n" copyInstaller installers}
      ${lib.concatMapStringsSep "\n" copyComponent components}

      unstick $TEMP/${(builtins.head installers).name} \
        --disable-components ${lib.concatStringsSep "," disabledComponents} \
        --mode unattended --installdir $out --accept_eula 1

      # required for 18.1
      patch --force --strip 0 --directory $out < ${./vsim.patch}

      rm -r $out/uninstall $out/logs
    '';

  meta = with lib; {
    inherit homepage;
    description = "FPGA design and simulation software";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = platforms.linux;
    hydraPlatforms = [ ]; # requireFile srcs cannot be fetched by hydra, ignore
    maintainers = with maintainers; [ haoxiangliew ];
  };
}
