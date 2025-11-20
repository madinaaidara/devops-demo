@extends('layouts.app')

@section('content')
<h1>Produits</h1>

<a href="{{ route('products.create') }}">Ajouter un produit</a>

@if(session('success'))<div>{{ session('success') }}</div>@endif

<table>
    <thead><tr><th>ID</th><th>Nom</th><th>Prix</th><th>Actions</th></tr></thead>
    <tbody>
    @foreach($products as $p)
    <tr>
        <td>{{ $p->id }}</td>
        <td>{{ $p->name }}</td>
        <td>{{ number_format($p->price,2) }} €</td>
        <td>
            <a href="{{ route('products.edit', $p) }}">Éditer</a>
            <form action="{{ route('products.destroy', $p) }}" method="POST" style="display:inline">
                @csrf @method('DELETE')
                <button type="submit" onclick="return confirm('Supprimer ?')">Supprimer</button>
            </form>
        </td>
    </tr>
    @endforeach
    </tbody>
</table>

{{ $products->links() }}
@endsection
