import type { Metadata } from "next";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Admin products",
  description: "List, search and archive products.",
};

export default function AdminProductsPage() {
  return (
    <PagePlaceholder
      title="Products"
      description="Every product with its status and category. Products are archived, never deleted, so old orders stay intact."
      task="Task 8"
    />
  );
}