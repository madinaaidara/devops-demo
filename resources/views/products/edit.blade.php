@extends('layouts.app')
@section('content')
<h1>Éditer le produit</h1>
@include('products._form', ['action' => route('products.update', $product), 'method' => 'PUT', 'product' => $product])
@endsection
