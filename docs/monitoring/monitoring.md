# System Monitoring

`btop` is a modern resource monitor that shows CPU, memory, disk, and network usage with an interactive and colorful interface.

---

## Loading Btop

```bash
ml btop
btop
```

Use {kbd}`Esc` or {kbd}`q` to quit.
```{hint}
Find yourself using btop often? you can add `ml btop` to your .zshrc
```

---

## Basic Navigation

|Key|Action|
|---|---|
|{kbd}`↑` / {kbd}`↓`|Move between sections|
|{kbd}`←` / {kbd}`→`|Change active graphs|
|{kbd}`m` / {kbd}`Esc`|Open or cycle the menus|
|{kbd}`o` / {kbd}`F2`|Open the options menu|
|{kbd}`f`|Open process filter|
|{kbd}`q`|Exit `btop`|

```{note}
it's possible to enable vim keybinds from the options menu
```

---

## Configuration

To customize appearance and behavior, edit the config file:

```bash
vim ~/.config/btop/btop.conf
```

You can also press {kbd}`o` (or {kbd}`F2`) inside `btop` to open the options menu.

---

## More Info

- Project page: [https://github.com/aristocratos/btop](https://github.com/aristocratos/btop)
- Run `btop --help` for command-line options.
