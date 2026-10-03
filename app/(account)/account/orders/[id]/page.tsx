import type { Metadata } from "next";
import { Suspense } from "react";

import { PagePlaceholder } from "@/components/shared/page-placeholder";

export const metadata: Metadata = {
  title: "Order details",
  description: "One of your orders.",
};

type OrderDetailsPageProps = {
  params: Promise<{ id: string }>;
};

async function OrderDetailsContent({ params }: OrderDetailsPageProps) {
  const { id } = await params;

  return (
    <PagePlaceholder
      title="Order details"
      description={`The line items for order ${id}, taken from the stored order snapshot, plus the delivery address and the status history. Internal IDs are never shown as the order number.`}
      task="Task 7"
    />
  );
}

export default function OrderDetailsPage({ params }: OrderDetailsPageProps) {
  return (
    <Suspense
      fallback={
        <PagePlaceholder title="Order details" description="Loading..." />
      }
    >
      <OrderDetailsContent params={params} />
    </Suspense>
  );
}