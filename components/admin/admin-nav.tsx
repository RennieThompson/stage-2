import Link from "next/link";

export const ADMIN_LINKS = [
  { href: "/admin", label: "Dashboard" },
  { href: "/admin/products", label: "Products" },
  { href: "/admin/categories", label: "Categories" },
  { href: "/admin/inventory", label: "Inventory" },
  { href: "/admin/orders", label: "Orders" },
];

export function AdminNav() {
  return (
    <nav aria-label="Admin" className="w-full">
      <ul className="flex flex-wrap gap-2">
        {ADMIN_LINKS.map((link) => (
          <li key={link.href}>
            <Link
              href={link.href}
              className="inline-flex items-center rounded-md border px-3 py-1.5 text-sm text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
            >
              {link.label}
            </Link>
          </li>
        ))}
      </ul>
    </nav>
  );
}