<form method="POST" action="{{ $action }}">
    @csrf
    @if($method === 'PUT') @method('PUT') @endif

    <div>
        <label>Nom</label>
        <input type="text" name="name" value="{{ old('name', $product->name ?? '') }}">
        @error('name')<div>{{ $message }}</div>@enderror
    </div>

    <div>
        <label>Prix</label>
        <input type="text" name="price" value="{{ old('price', $product->price ?? '') }}">
        @error('price')<div>{{ $message }}</div>@enderror
    </div>

    <button type="submit">Enregistrer</button>
</form>
