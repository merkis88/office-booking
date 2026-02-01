<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\UserStoreRequest;
use App\Http\Requests\UserUpdatePasswordRequest;
use http\Env\Response;
use Illuminate\Http\Request;
use App\Models\User;
use App\Http\Resources\UserResource;
use App\Http\Requests\UserUpdateRequest;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules\Password;

class UserController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return UserResource::collection(User::all());
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(UserStoreRequest $request)
    {
        $validated = $request->validated();


        if(isset($validated['password'])){
            $validated['password'] = Hash::make($validated['password']);
        }
        $created_user = User::create($validated);
        return new UserResource($created_user);
    }

    /**
     * Display the specified resource.
     */
    public function show(User $user)
    {
        return new UserResource($user);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UserUpdateRequest $request, User $user)
    {
        $data =$request->validated();
        if($request->has('password')) {
            $data['password'] = Hash::make($request->password);
        }
        $user->update($data);
        return new UserResource($user);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(User $user)
    {
        $user->delete();
        return response(null,204);
    }

    public function updatePassword(UserUpdatePasswordRequest $request)
    {
        $validated = $request->validated();
        $request->user()->update([
            'password' => Hash::make($validated['password']),
        ]);
        return response()->json(['message' => 'Password updated successfully.'], 200);
    }
}
