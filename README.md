# Uridium-SC3000-ASC16L

Port of Artrag's Uridium (MSX1) to the Sega SC-3000, using the ASC16L mapper.

This repository contains **source code only**. It does not include any graphics,
levels, music, sound effects or other game data, and no ROM images.

## Build

Requires [sjasmplus](https://github.com/z00m128/sjasmplus) (tested with v1.23.1).

    ./build.sh

The output is `URIDIUM.asc` (128 KB).

The build will not succeed until the data files listed below are placed in the
paths shown. They are not distributed here.

## Required data files

- `levels/`: `chr_plain1d_ms.miz chr_plain1u_ms.miz chr_plain2d_ms.miz chr_plain2u_ms.miz chr1_common.miz chr1_dw.miz chr1_up.miz chr2_common.miz chr2_dw.miz chr2_up.miz clr_plain1_ms.miz clr_plain2_ms.miz clr1_common.miz clr1_ud.miz clr2_common.miz clr2_ud.miz lev_1.miz lev_2.miz lev_3.miz lev_4.miz lev_5.miz lev_6.miz lev_7.miz lev_8.miz lev_9.miz lev_A.miz lev_B.miz lev_C.miz lev_D.miz lev_E.miz lev_F.miz lev_ms.miz meta_pnt_table_d_ms.miz meta_pnt_table_d.miz meta_pnt_table_u_ms.miz meta_pnt_table_u.miz`
- `graphic/`: `bmp105/bonus.mgb bonus.bin destr_col.bin destr_shape.bin ENDING2_chr.miz ENDING2_clr.miz MANTA_clrs.miz MANTA_shps.miz uridium_rev6b.miz uridium_rev8.miz`
- `mus/`: `UR_ENDING.PSG UR_MUTE.PSG UR_TITLE.PSG`
- `afx/`: `alarm.wav_sn76489.bin Bombs_in_place.wav_sn76489.bin Enemies.wav_sn76489.bin explosion.wav_sn76489.bin Game_over.wav_sn76489.bin land_now.wav_sn76489.bin level_completed.wav_sn76489.bin No_not_now.wav_sn76489.bin shoot_up.wav_sn76489.bin syren.wav_sn76489.bin watch_out.wav_sn76489.bin watch_your_back.wav_sn76489.bin`
- `options/`: `ENDINGPI.col.pck ENDINGPI.nam.pck ENDINGPI.til.pck LOADING_.color.pck LOADING_.nam.pck LOADING_.patt.pck uridium_font2.bin`
- project root: `ms_demo_frm.bin sfx_data.asm`

## Credits

- Original game: Uridium, Hewson Consultants (Andrew Braybrook / Dominic Robinson).
- MSX1 version and original code: Arturo Ragozzini (Artrag),
  <https://github.com/artrag/Uridium-msx1>, used here with his kind permission to create this release.
- SC-3000 / ASC16L port: siriokds.

See NOTICE.
