import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Admin categories",
  description: "Create and order product categories.",
};

export default function AdminCategoriesPage() {
  return (
    <PagePlaceholder
      title="Categories"
      description="Create, rename, reorder and archive categories. Category links on the storefront always come from the database."
      task="Task 8"
    />
  );
}