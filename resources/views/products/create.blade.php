@extends('layouts.app')
@section('content')
<h1>Ajouter un produit</h1>
@include('products._form', ['action' => route('products.store'), 'method' => 'POST', 'product' => null])
@endsection
