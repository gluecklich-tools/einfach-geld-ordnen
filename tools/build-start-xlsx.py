from __future__ import annotations

import argparse
import json
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any

from openpyxl import load_workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.cell.cell import MergedCell


TARGET_SHEET = "START"
TARGET_RANGE = ("A1", "I20")
ZONE_COLUMNS = {
    "left": ("A", "C"),
    "center": ("D", "F"),
    "right": ("G", "I"),
}

NAVY = "1F3A5F"
NAVY_DARK = "17314F"
BLUE_SOFT = "EAF1FB"
BLUE_MID = "DCE8F8"
ALT_SOFT = "F7F9FC"
TEXT_DARK = "203040"
TEXT_MID = "4B5D73"
WHITE = "FFFFFF"
BORDER = "C9D6E8"


@dataclass
class CellSnapshot:
    coord: str
    value: str
    fill_rgb: str | None
    is_merged: bool


@dataclass
class StartSnapshot:
    workbook_path: str
    sheet_name: str
    max_row: int
    max_column: int
    merged_ranges: list[str]
    row_heights: dict[str, float | None]
    column_widths: dict[str, float | None]
    non_empty_cells: list[CellSnapshot]
    target_range: dict[str, str]
    zone_columns: dict[str, tuple[str, str]]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Deterministic START sheet XLSX builder.")
    parser.add_argument("--input", required=True, help="Path to source xlsx")
    parser.add_argument("--output", required=True, help="Path to output xlsx")
    parser.add_argument("--report", required=True, help="Path to json report")
    parser.add_argument(
        "--mode",
        choices=("snapshot", "dry-run", "apply"),
        default="snapshot",
        help="snapshot=dump state, dry-run=plan only, apply=write output workbook",
    )
    parser.add_argument("--force", action="store_true", help="Allow overwriting output file")
    return parser.parse_args()


def fail(message: str) -> None:
    raise SystemExit(f"FAIL: {message}")


def hex_fill(rgb: str) -> PatternFill:
    return PatternFill(fill_type="solid", fgColor=rgb)


def thin_border(color: str = BORDER) -> Border:
    side = Side(style="thin", color=color)
    return Border(left=side, right=side, top=side, bottom=side)


def get_fill_rgb(cell: Any) -> str | None:
    fill = cell.fill
    if fill is None:
        return None
    if fill.fill_type is None:
        return None
    fg = fill.fgColor
    rgb = getattr(fg, "rgb", None)
    if rgb:
        return str(rgb)
    indexed = getattr(fg, "indexed", None)
    if indexed is not None:
        return f"indexed:{indexed}"
    theme = getattr(fg, "theme", None)
    if theme is not None:
        return f"theme:{theme}"
    return None


def merged_coord_set(ws: Any) -> set[str]:
    result: set[str] = set()
    for merged in ws.merged_cells.ranges:
        for row in ws[str(merged)]:
            for cell in row:
                result.add(cell.coordinate)
    return result


def snapshot_sheet(workbook_path: Path, ws: Any) -> StartSnapshot:
    merged_ranges = [str(rng) for rng in ws.merged_cells.ranges]
    merged_cells = merged_coord_set(ws)

    row_heights: dict[str, float | None] = {}
    for row_idx in range(1, 21):
        row_heights[str(row_idx)] = ws.row_dimensions[row_idx].height

    column_widths: dict[str, float | None] = {}
    for col in ("A", "B", "C", "D", "E", "F", "G", "H", "I"):
        column_widths[col] = ws.column_dimensions[col].width

    non_empty_cells: list[CellSnapshot] = []
    for row in ws["A1:I20"]:
        for cell in row:
            if cell.value is None:
                continue
            non_empty_cells.append(
                CellSnapshot(
                    coord=cell.coordinate,
                    value=str(cell.value),
                    fill_rgb=get_fill_rgb(cell),
                    is_merged=cell.coordinate in merged_cells,
                )
            )

    return StartSnapshot(
        workbook_path=str(workbook_path),
        sheet_name=ws.title,
        max_row=ws.max_row,
        max_column=ws.max_column,
        merged_ranges=merged_ranges,
        row_heights=row_heights,
        column_widths=column_widths,
        non_empty_cells=non_empty_cells,
        target_range={"from": TARGET_RANGE[0], "to": TARGET_RANGE[1]},
        zone_columns=ZONE_COLUMNS,
    )


def write_json_report(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")


def safe_cells(ws: Any, ref: str):
    for row in ws[ref]:
        for cell in row:
            if isinstance(cell, MergedCell):
                continue
            yield cell


def style_range(ws: Any, ref: str, *, fill: str | None = None, font: Font | None = None,
                alignment: Alignment | None = None, border: Border | None = None) -> None:
    for cell in safe_cells(ws, ref):
        if fill is not None:
            cell.fill = hex_fill(fill)
        if font is not None:
            cell.font = font
        if alignment is not None:
            cell.alignment = alignment
        if border is not None:
            cell.border = border


def apply_step1_refine(ws: Any) -> list[str]:
    changes: list[str] = []

    # Stronger row rhythm and presence
    ws.row_dimensions[1].height = 54
    ws.row_dimensions[3].height = 24
    ws.row_dimensions[4].height = 52
    ws.row_dimensions[5].height = 32
    ws.row_dimensions[6].height = 32
    ws.row_dimensions[7].height = 32
    ws.row_dimensions[8].height = 32
    ws.row_dimensions[9].height = 34
    ws.row_dimensions[10].height = 34
    ws.row_dimensions[13].height = 28
    ws.row_dimensions[14].height = 30
    ws.row_dimensions[15].height = 30
    ws.row_dimensions[16].height = 30
    ws.row_dimensions[17].height = 30
    ws.row_dimensions[18].height = 30
    ws.row_dimensions[20].height = 24
    changes.append("row rhythm strengthened for architecture lift")

    # Title + status more sovereign
    style_range(
        ws,
        "A1:I1",
        fill=NAVY,
        font=Font(name="Calibri", size=26, bold=True, color=WHITE),
        alignment=Alignment(horizontal="left", vertical="center"),
        border=thin_border(NAVY_DARK),
    )
    style_range(
        ws,
        "A3:F3",
        fill="E8F1FD",
        font=Font(name="Calibri", size=11, bold=True, color=TEXT_DARK),
        alignment=Alignment(horizontal="left", vertical="center"),
        border=thin_border(),
    )
    style_range(
        ws,
        "G3:I3",
        fill="CEDFF6",
        font=Font(name="Calibri", size=12, bold=True, color=NAVY_DARK),
        alignment=Alignment(horizontal="center", vertical="center"),
        border=thin_border(),
    )
    changes.append("header zone made more sovereign")

    # Left / center / right block with stronger separation
    style_range(
        ws,
        "A4:C10",
        fill="FBFDFF",
        font=Font(name="Calibri", size=11, color=TEXT_MID),
        alignment=Alignment(horizontal="left", vertical="center", wrap_text=True),
        border=thin_border(),
    )
    style_range(
        ws,
        "D4:F10",
        fill="E4EEFD",
        font=Font(name="Calibri", size=12, color=TEXT_DARK),
        alignment=Alignment(horizontal="center", vertical="center", wrap_text=True),
        border=thin_border(),
    )
    style_range(
        ws,
        "G4:I10",
        fill="F7FAFE",
        font=Font(name="Calibri", size=11, color=TEXT_DARK),
        alignment=Alignment(horizontal="left", vertical="center", wrap_text=True),
        border=thin_border(),
    )
    changes.append("three-zone architecture separated more clearly")

    # Center block drama without dashboard aggression
    style_range(
        ws,
        "D4:F4",
        fill="D7E6FB",
        font=Font(name="Calibri", size=12, bold=True, color=TEXT_MID),
        alignment=Alignment(horizontal="center", vertical="center"),
        border=thin_border(),
    )
    style_range(
        ws,
        "D5:F6",
        fill="D3E4FC",
        font=Font(name="Calibri", size=15, bold=True, color=TEXT_DARK),
        alignment=Alignment(horizontal="center", vertical="center"),
        border=thin_border(),
    )
    style_range(
        ws,
        "D7:F8",
        fill="D0E1FB",
        font=Font(name="Calibri", size=15, bold=True, color=TEXT_DARK),
        alignment=Alignment(horizontal="center", vertical="center"),
        border=thin_border(),
    )
    style_range(
        ws,
        "D9:F10",
        fill="C4D9F6",
        font=Font(name="Calibri", size=17, bold=True, color=NAVY_DARK),
        alignment=Alignment(horizontal="center", vertical="center", wrap_text=True),
        border=thin_border(),
    )
    changes.append("center block gained stronger focal hierarchy")

    # Left labels more restrained and orderly
    style_range(
        ws,
        "A5:C10",
        fill="FAFCFF",
        font=Font(name="Calibri", size=11, bold=False, color=TEXT_MID),
        alignment=Alignment(horizontal="left", vertical="center"),
        border=thin_border(),
    )
    changes.append("left overview block made calmer")

    # Right orientation consciously framed
    style_range(
        ws,
        "G4:I4",
        fill="E3EDF9",
        font=Font(name="Calibri", size=12, bold=True, color=NAVY_DARK),
        alignment=Alignment(horizontal="left", vertical="center"),
        border=thin_border(),
    )
    style_range(
        ws,
        "G5:I10",
        fill="F7FAFE",
        font=Font(name="Calibri", size=11, color=TEXT_DARK),
        alignment=Alignment(horizontal="left", vertical="center", wrap_text=True),
        border=thin_border(),
    )
    changes.append("right guidance block framed as premium helper zone")

    # Top expenses more report-like
    style_range(
        ws,
        "A13:I13",
        fill=NAVY_DARK,
        font=Font(name="Calibri", size=13, bold=True, color=WHITE),
        alignment=Alignment(horizontal="left", vertical="center"),
        border=thin_border(NAVY_DARK),
    )
    style_range(
        ws,
        "A14:F18",
        fill=WHITE,
        font=Font(name="Calibri", size=11, color=TEXT_DARK),
        alignment=Alignment(horizontal="left", vertical="center"),
        border=thin_border(),
    )
    style_range(
        ws,
        "G14:I18",
        fill="E4EEFD",
        font=Font(name="Calibri", size=11, bold=True, color=NAVY_DARK),
        alignment=Alignment(horizontal="right", vertical="center"),
        border=thin_border(),
    )
    changes.append("top expenses lifted into stronger report section")

    # Footer
    style_range(
        ws,
        "A20:I20",
        fill="EEF4FC",
        font=Font(name="Calibri", size=10, italic=True, color=TEXT_MID),
        alignment=Alignment(horizontal="left", vertical="center"),
        border=thin_border(),
    )
    changes.append("footer kept anchored")

    return changes


def clone_workbook_to_output(src: Path, dst: Path, force: bool) -> Any:
    if dst.exists() and not force:
        fail(f"output exists and --force missing: {dst}")
    dst.parent.mkdir(parents=True, exist_ok=True)
    wb = load_workbook(src)
    return wb


def main() -> None:
    args = parse_args()

    input_path = Path(args.input).resolve()
    output_path = Path(args.output).resolve()
    report_path = Path(args.report).resolve()

    if not input_path.exists():
        fail(f"input not found: {input_path}")
    if input_path.suffix.lower() != ".xlsx":
        fail(f"input must be .xlsx: {input_path}")

    wb = load_workbook(input_path)
    if TARGET_SHEET not in wb.sheetnames:
        fail(f"sheet not found: {TARGET_SHEET}")

    ws = wb[TARGET_SHEET]
    snap = snapshot_sheet(input_path, ws)

    payload: dict[str, Any] = {
        "status": "PASS",
        "mode": args.mode,
        "sheet": asdict(snap),
        "notes": [
            "Step1 premium refine keeps architecture intact.",
            "Focus is visual hierarchy, rhythm, report feel and anchored zones.",
            "No architectural rebuild in this step.",
        ],
    }

    if args.mode == "snapshot":
        write_json_report(report_path, payload)
        print(f"REPORT: {report_path}")
        print("PASS: build-start-xlsx snapshot")
        return

    if args.mode == "dry-run":
        payload["dry_run"] = {
            "would_write_output": str(output_path),
            "planned_transformations": [
                "title/status refine",
                "main block fill/hierarchy unify",
                "center KPI emphasis",
                "top-expenses report styling",
                "footer anchor styling",
            ],
        }
        write_json_report(report_path, payload)
        print(f"REPORT: {report_path}")
        print("PASS: build-start-xlsx dry-run")
        return

    wb = clone_workbook_to_output(input_path, output_path, args.force)
    ws = wb[TARGET_SHEET]
    applied = apply_step1_refine(ws)
    wb.save(output_path)

    payload["apply"] = {
        "output_written": str(output_path),
        "transformations_applied": applied,
        "message": "Step1 premium refine applied to existing START architecture.",
    }
    write_json_report(report_path, payload)
    print(f"OUTPUT: {output_path}")
    print(f"REPORT: {report_path}")
    print("PASS: build-start-xlsx apply")
    return


if __name__ == "__main__":
    main()