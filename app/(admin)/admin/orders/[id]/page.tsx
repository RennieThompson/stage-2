import type { Metadata } from "next";
import { Suspense } from "react";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Admin order details",
  description: "Customer, delivery and payment details for one order.",
};

type AdminOrderDetailsPageProps = {
  params: Promise<{ id: string }>;
};

async function AdminOrderDetailsContent({
  params,
}: AdminOrderDetailsPageProps) {
  const { id } = await params;

  return (
    <PagePlaceholder
      title="Order details"
      description={`Customer and delivery information for order ${id}, the payment attempts, the status history and the status and payment controls.`}
      task="Task 9"
    />
  );
}

export default function AdminOrderDetailsPage({
  params,
}: AdminOrderDetailsPageProps) {
  return (
    <Suspense
      fallback={
        <PagePlaceholder title="Order details" description="Loading..." />
      }
    >
      <AdminOrderDetailsContent params={params} />
    </Suspense>
  );
}