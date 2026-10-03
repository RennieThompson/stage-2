/**
 * Money helpers.
 *
 * Every amount in the database is an integer in minor units (kobo for NGN).
 * Never use floats for money: use these helpers to turn minor units into a
 * display string or, when reading a form value, into minor units.
 */

/**
 * Fallback currency code. The live currency comes from `store_settings` once
 * Task 1 creates the table.
 */
export const DEFAULT_CURRENCY = "NGN";

/** Locale used for grouping and symbol placement by default. */
export const DEFAULT_LOCALE = "en-NG";

/** 100 kobo = 1 naira. */
const MINOR_UNITS_PER_MAJOR = 100;

/** Convert an integer amount in minor units into major units (for example kobo to naira). */
export function toMajorUnits(amountMinor: number): number {
  assertIntegerMinorUnits(amountMinor);
  return amountMinor / MINOR_UNITS_PER_MAJOR;
}

/** Convert an amount in major units into integer minor units, rounding to the nearest unit. */
export function toMinorUnits(amountMajor: number): number {
  if (!Number.isFinite(amountMajor)) {
    throw new TypeError(`Money must be a finite number. Received ${amountMajor}.`);
  }
  return Math.round(amountMajor * MINOR_UNITS_PER_MAJOR);
}

/**
 * Format an integer amount in minor units as a currency string.
 *
 * @example
 * formatMoney(450000); // "₦4,500.00"
 */
export function formatMoney(
  amountMinor: number,
  currency: string = DEFAULT_CURRENCY,
  locale: string = DEFAULT_LOCALE,
): string {
  assertIntegerMinorUnits(amountMinor);

  return new Intl.NumberFormat(locale, {
    style: "currency",
    currency,
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(amountMinor / MINOR_UNITS_PER_MAJOR);
}

function assertIntegerMinorUnits(amountMinor: number): void {
  if (!Number.isInteger(amountMinor)) {
    throw new TypeError(
      `Money must be an integer in minor units. Received ${amountMinor}.`,
    );
  }
}