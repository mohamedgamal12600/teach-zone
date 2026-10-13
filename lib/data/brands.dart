// brands.dart
// Master list of brands and logos used in TechZone.

import '../models/brand.dart';

const List<Brand> brands = [
  Brand(
    name: 'Sony',
    logoUrl: 'https://www.google.com/s2/favicons?domain=sony.com&sz=128',
  ),
  Brand(
    name: 'Microsoft',
    logoUrl: 'https://www.google.com/s2/favicons?domain=microsoft.com&sz=128',
  ),
  Brand(
    name: 'Nintendo',
    logoUrl: 'https://www.google.com/s2/favicons?domain=nintendo.com&sz=128',
  ),
  Brand(
    name: 'Apple',
    logoUrl: 'https://www.google.com/s2/favicons?domain=apple.com&sz=128',
  ),
  Brand(
    name: 'Dell',
    logoUrl: 'https://www.google.com/s2/favicons?domain=dell.com&sz=128',
  ),
  Brand(
    name: 'ASUS',
    logoUrl: 'https://www.google.com/s2/favicons?domain=asus.com&sz=128',
  ),
  Brand(
    name: 'Lenovo',
    logoUrl: 'https://www.google.com/s2/favicons?domain=lenovo.com&sz=128',
  ),
  Brand(
    name: 'HP',
    logoUrl: 'https://www.google.com/s2/favicons?domain=hp.com&sz=128',
  ),
  Brand(
    name: 'Samsung',
    logoUrl: 'https://www.google.com/s2/favicons?domain=samsung.com&sz=128',
  ),
  Brand(
    name: 'Google',
    logoUrl: 'https://www.google.com/s2/favicons?domain=store.google.com&sz=128',
  ),
  Brand(
    name: 'OnePlus',
    logoUrl: 'https://www.google.com/s2/favicons?domain=oneplus.com&sz=128',
  ),
  Brand(
    name: 'Xiaomi',
    logoUrl: 'https://www.google.com/s2/favicons?domain=mi.com&sz=128',
  ),
  Brand(
    name: 'Bose',
    logoUrl: 'https://www.google.com/s2/favicons?domain=bose.com&sz=128',
  ),
  Brand(
    name: 'Logitech',
    logoUrl: 'https://www.google.com/s2/favicons?domain=logitech.com&sz=128',
  ),
  Brand(
    name: 'Anker',
    logoUrl: 'https://www.google.com/s2/favicons?domain=anker.com&sz=128',
  ),
  Brand(
    name: 'Meta',
    logoUrl: 'https://www.google.com/s2/favicons?domain=meta.com&sz=128',
  ),
  Brand(
    name: 'Razer',
    logoUrl: 'https://www.google.com/s2/favicons?domain=razer.com&sz=128',
  ),
  Brand(
    name: 'SteelSeries',
    logoUrl: 'https://www.google.com/s2/favicons?domain=steelseries.com&sz=128',
  ),
  Brand(
    name: 'Elgato',
    logoUrl: 'https://www.google.com/s2/favicons?domain=elgato.com&sz=128',
  ),
];

/// Quick lookup map for brand logos by name
final Map<String, String> brandLogos = {
  for (final b in brands) b.name: b.logoUrl,
};
