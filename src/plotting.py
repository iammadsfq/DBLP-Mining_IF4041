"""Publication-grade matplotlib styling and export helpers (figures4papers standard)."""

import os
import matplotlib.pyplot as plt

PALETTE = {
    "blue_main": "#0F4D92",
    "blue_secondary": "#3775BA",
    "green_1": "#DDF3DE",
    "green_2": "#AADCA9",
    "green_3": "#8BCF8B",
    "red_1": "#F6CFCB",
    "red_2": "#E9A6A1",
    "red_strong": "#B64342",
    "neutral": "#CFCECE",
    "highlight": "#FFD700",
    "teal": "#42949E",
    "violet": "#9A4D8E",
}


def apply_publication_style(base_font_size: int = 12, axes_linewidth: float = 2.0) -> None:
    """Apply clean publication-ready matplotlib defaults."""
    plt.rcParams.update({
        "font.family": "sans-serif",
        "font.sans-serif": ["Arial", "Helvetica", "DejaVu Sans", "sans-serif"],
        "font.size": base_font_size,
        "axes.titlesize": base_font_size + 2,
        "axes.titleweight": "bold",
        "axes.labelsize": base_font_size,
        "axes.labelweight": "bold",
        "axes.linewidth": axes_linewidth,
        "axes.spines.top": False,
        "axes.spines.right": False,
        "xtick.labelsize": base_font_size - 1,
        "ytick.labelsize": base_font_size - 1,
        "xtick.major.width": axes_linewidth * 0.8,
        "ytick.major.width": axes_linewidth * 0.8,
        "legend.frameon": False,
        "legend.fontsize": base_font_size - 1,
        "figure.dpi": 150,
        "savefig.dpi": 300,
        "svg.fonttype": "none",
    })


def clean_axes(ax, grid_axis: str = "y") -> None:
    """Ensure top/right spines are hidden and subtle dashed gridlines are applied."""
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    if grid_axis in ("x", "y", "both"):
        ax.grid(axis=grid_axis, linestyle="--", alpha=0.35, color="#888888")
        ax.set_axisbelow(True)


def save_figure(fig, base_path_without_ext: str, dpi: int = 300, pad: float = 1.2) -> tuple[str, str]:
    """Tighten layout and export figure to both PNG and PDF."""
    os.makedirs(os.path.dirname(os.path.abspath(base_path_without_ext)), exist_ok=True)
    fig.tight_layout(pad=pad)
    png_path = f"{base_path_without_ext}.png"
    pdf_path = f"{base_path_without_ext}.pdf"
    fig.savefig(png_path, dpi=dpi, bbox_inches="tight")
    fig.savefig(pdf_path, bbox_inches="tight")
    return png_path, pdf_path
