import 'package:flutter/material.dart';
import 'package:petshop/model/checkout_response_modal.dart';
import 'package:petshop/components/dialog_utils.dart';

class CartItemCard extends StatelessWidget {
  final CheckoutLineCheckoutResponse cartItem;

  const CartItemCard({
    required this.cartItem,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cartItem.variant),
      background: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => showConfirmDialog(
        context,
        'Do you want to remove the item from the cart?',
      ),
      onDismissed: (direction) {
        print('Cart item dismissed');
      },
      child: buildItemCard(),
    );
  }

  Widget buildItemCard() {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: FittedBox(
                child: Text('\$${'cartItem.price'}'),
              ),
            ),
          ),
          title: Text(cartItem?.variant.product.name ?? ''),
          subtitle: Text('Total: \$${'cartItem.price * cartItem.quantity'}'),
          trailing: Text('${cartItem?.quantity}x'),
        ),
      ),
    );
  }
}
