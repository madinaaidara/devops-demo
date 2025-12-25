<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Liste des produits</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        body {
            font-family: Arial, Helvetica, sans-serif;
            background-color: #f4f6f8;
            margin: 0;
            padding: 0;
        }

        .container {
            max-width: 1100px;
            margin: 40px auto;
            background: #ffffff;
            padding: 25px;
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.08);
        }

        h1 {
            margin-top: 0;
            color: #2c3e50;
        }

        a.btn {
            display: inline-block;
            margin-bottom: 15px;
            padding: 8px 14px;
            background: #3498db;
            color: #fff;
            text-decoration: none;
            border-radius: 4px;
            font-size: 14px;
        }

        a.btn:hover {
            background: #2980b9;
        }

        .alert-success {
            background: #d4edda;
            color: #155724;
            padding: 10px 15px;
            border-radius: 4px;
            margin-bottom: 15px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }

        table th {
            background: #ecf0f1;
            padding: 10px;
            text-align: left;
        }

        table td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }

        .actions a {
            margin-right: 10px;
            color: #2980b9;
            text-decoration: none;
            font-weight: bold;
        }

        .actions button {
            background: #e74c3c;
            color: #fff;
            border: none;
            padding: 5px 10px;
            border-radius: 3px;
            cursor: pointer;
        }

        .actions button:hover {
            background: #c0392b;
        }

        .empty {
            text-align: center;
            color: #777;
            padding: 15px;
        }

        .pagination {
            margin-top: 20px;
        }
    </style>
</head>
<body>

<div class="container">

    <h1>Liste des produits</h1>

    <a href="{{ route('products.create') }}" class="btn">
        + Ajouter un produit
    </a>

    @if(session('success'))
        <div class="alert-success">
            {{ session('success') }}
        </div>
    @endif

    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Nom</th>
                <th>Prix (€)</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
        @forelse($products as $p)
            <tr>
                <td>{{ $p->id }}</td>
                <td>{{ $p->name }}</td>
                <td>{{ number_format($p->price, 2) }}</td>
                <td class="actions">
                    <a href="{{ route('products.edit', $p) }}">Éditer</a>

                    <form action="{{ route('products.destroy', $p) }}" method="POST" style="display:inline">
                        @csrf
                        @method('DELETE')
                        <button type="submit" onclick="return confirm('Supprimer ce produit ?')">
                            Supprimer
                        </button>
                    </form>
                </td>
            </tr>
        @empty
            <tr>
                <td colspan="4" class="empty">
                    Aucun produit enregistré.
                </td>
            </tr>
        @endforelse
        </tbody>
    </table>

    {{ $products->links() }}

</div>

</body>
</html>
